const fs = require("fs");
const path = require("path");
const circomlibjs = require("circomlibjs");

// Experiment input generator
// Purpose:
// - scalable experiment data generation
// - supports variable nSeller / nBuyer
// - aligned with current Phase 3 message-format circuit
//
// Usage:
//   node scripts/gen_input_experiment.js <nSeller> <nBuyer> <mode> [epoch] [price]
//
// Example:
//   node scripts/gen_input_experiment.js 4 4 balanced
//   node scripts/gen_input_experiment.js 8 8 seller_gt_buyer
//   node scripts/gen_input_experiment.js 8 8 buyer_gt_seller
//   node scripts/gen_input_experiment.js 8 8 mixed_cases
//
// Supported modes:
//   balanced         -> sellerSum == buyerSum
//   seller_gt_buyer  -> sellerSum > buyerSum  => balDSOSign = 1
//   buyer_gt_seller  -> sellerSum < buyerSum  => balDSOSign = 0
//   mixed_cases      -> mix of sellCase / buyCase across participants
//   all_leq          -> all Actual <= Claim
//   all_gt           -> all Actual > Claim

function parsePositiveInt(value, name) {
  const n = Number.parseInt(value, 10);
  if (!Number.isInteger(n) || n <= 0) {
    throw new Error(`${name} must be a positive integer, got: ${value}`);
  }
  return n;
}

function bigIntArrayToString(arr) {
  return arr.map((x) => x.toString());
}

function sumBigInt(arr) {
  return arr.reduce((acc, x) => acc + x, 0n);
}

function repeatArray(length, fn) {
  return Array.from({ length }, (_, i) => fn(i));
}

async function main() {
  const nSeller = parsePositiveInt(process.argv[2] || "1", "nSeller");
  const nBuyer = parsePositiveInt(process.argv[3] || "1", "nBuyer");
  const mode = process.argv[4] || "balanced";
  const epoch = BigInt(process.argv[5] || "1");
  const price = BigInt(process.argv[6] || "10");

  const poseidon = await circomlibjs.buildPoseidon();
  const F = poseidon.F;

  const hashToString = (inputs) => F.toString(poseidon(inputs));

  // -------------------------
  // domain tags
  // -------------------------
  const PRICE = 297481622096n;
  const CLAIMSELL = 1407448440113608084547n;
  const CLAIMBUY = 6437124142104923203n;
  const ACTSELL = 21475958864495425n;
  const ACTBUY = 98222719910721n;

  // -------------------------
  // price witness
  // -------------------------
  const rPrice = 123n;
  const saltPrice = 456n;

  // -------------------------
  // identifiers
  // -------------------------
  const offerId = repeatArray(nSeller, (i) => 1001n + BigInt(i));
  const orderId = repeatArray(nBuyer, (j) => 2001n + BigInt(j));

  const sellMeterId = repeatArray(nSeller, (i) => 3001n + BigInt(i));
  const buyMeterId = repeatArray(nBuyer, (j) => 4001n + BigInt(j));

  const tSellClaim = repeatArray(nSeller, (i) => 10001n + BigInt(i));
  const tBuyClaim = repeatArray(nBuyer, (j) => 11001n + BigInt(j));

  const tSellActual = repeatArray(nSeller, (i) => 12001n + BigInt(i));
  const tBuyActual = repeatArray(nBuyer, (j) => 13001n + BigInt(j));

  // -------------------------
  // salts
  // -------------------------
  const saltClaimSell = repeatArray(nSeller, (i) => 20001n + BigInt(i));
  const saltSell = repeatArray(nSeller, (i) => 21001n + BigInt(i));

  const saltClaimBuy = repeatArray(nBuyer, (j) => 22001n + BigInt(j));
  const saltBuy = repeatArray(nBuyer, (j) => 23001n + BigInt(j));

  // -------------------------
  // energy values
  // -------------------------
  let claimSell = [];
  let sellActual = [];
  let claimBuy = [];
  let buyActual = [];

  // Base patterns
  const baseClaimSell = repeatArray(nSeller, (i) => 10n + BigInt(i % 5));
  const baseClaimBuy = repeatArray(nBuyer, (j) => 10n + BigInt(j % 5));

  if (mode === "balanced") {
    // All <=, and totals equal after actual values
    claimSell = [...baseClaimSell];
    sellActual = claimSell.map((x, i) => x - BigInt(i % 2)); // <= claim

    claimBuy = [...baseClaimBuy];
    buyActual = [...sellActual];

    // If seller/buyer counts differ, rebalance buyer side deterministically
    if (nBuyer !== nSeller) {
      buyActual = repeatArray(nBuyer, () => 1n);
      const target = sumBigInt(sellActual);
      let assigned = 0n;
      for (let j = 0; j < nBuyer; j++) {
        const remainingSlots = BigInt(nBuyer - j - 1);
        const remaining = target - assigned;
        const val = j === nBuyer - 1 ? remaining : remaining / (remainingSlots + 1n);
        buyActual[j] = val > 0n ? val : 1n;
        assigned += buyActual[j];
      }
      claimBuy = buyActual.map((x, j) => x + BigInt(j % 2)); // ensure actual <= claim
    }
  } else if (mode === "seller_gt_buyer") {
    // sellerSum > buyerSum => DSO pays
    claimSell = [...baseClaimSell];
    sellActual = claimSell.map((x) => x - 1n); // <= claim

    claimBuy = [...baseClaimBuy];
    buyActual = claimBuy.map((x) => x - 3n > 0n ? x - 3n : 1n); // <= claim
  } else if (mode === "buyer_gt_seller") {
    // sellerSum < buyerSum => DSO receives
    claimSell = [...baseClaimSell];
    sellActual = claimSell.map((x) => x - 3n > 0n ? x - 3n : 1n); // <= claim

    claimBuy = [...baseClaimBuy];
    buyActual = claimBuy.map((x) => x - 1n); // <= claim
  } else if (mode === "mixed_cases") {
    // mix sellCase / buyCase
    claimSell = [...baseClaimSell];
    sellActual = repeatArray(nSeller, (i) =>
      i % 2 === 0 ? claimSell[i] - 1n : claimSell[i] + 2n
    );

    claimBuy = [...baseClaimBuy];
    buyActual = repeatArray(nBuyer, (j) =>
      j % 2 === 0 ? claimBuy[j] : claimBuy[j] + 2n
    );
  } else if (mode === "all_leq") {
    claimSell = [...baseClaimSell];
    sellActual = claimSell.map((x, i) => x - BigInt((i % 3) + 1)).map((x) => (x > 0n ? x : 1n));

    claimBuy = [...baseClaimBuy];
    buyActual = claimBuy.map((x, j) => x - BigInt((j % 3) + 1)).map((x) => (x > 0n ? x : 1n));
  } else if (mode === "all_gt") {
    claimSell = [...baseClaimSell];
    sellActual = claimSell.map((x, i) => x + BigInt((i % 3) + 1));

    claimBuy = [...baseClaimBuy];
    buyActual = claimBuy.map((x, j) => x + BigInt((j % 3) + 1));
  } else {
    throw new Error(
      `Unknown mode: ${mode}. Supported: balanced, seller_gt_buyer, buyer_gt_seller, mixed_cases, all_leq, all_gt`
    );
  }

  // Safety: ensure all values stay positive and 64-bit friendly
  claimSell = claimSell.map((x) => (x > 0n ? x : 1n));
  sellActual = sellActual.map((x) => (x > 0n ? x : 1n));
  claimBuy = claimBuy.map((x) => (x > 0n ? x : 1n));
  buyActual = buyActual.map((x) => (x > 0n ? x : 1n));

  // -------------------------
  // commitments
  // -------------------------
  const H_price_epoch = hashToString([PRICE, epoch, price, rPrice, saltPrice]);

  const mClaimSell = repeatArray(nSeller, (i) =>
    hashToString([
      CLAIMSELL,
      epoch,
      offerId[i],
      claimSell[i],
      tSellClaim[i],
      saltClaimSell[i],
    ])
  );

  const mClaimBuy = repeatArray(nBuyer, (j) =>
    hashToString([
      CLAIMBUY,
      epoch,
      orderId[j],
      claimBuy[j],
      tBuyClaim[j],
      saltClaimBuy[j],
    ])
  );

  const mActualSell = repeatArray(nSeller, (i) =>
    hashToString([
      ACTSELL,
      epoch,
      offerId[i],
      sellMeterId[i],
      sellActual[i],
      tSellActual[i],
      saltSell[i],
    ])
  );

  const mActualBuy = repeatArray(nBuyer, (j) =>
    hashToString([
      ACTBUY,
      epoch,
      orderId[j],
      buyMeterId[j],
      buyActual[j],
      tBuyActual[j],
      saltBuy[j],
    ])
  );

  // -------------------------
  // classification bits
  // 0 -> Actual <= Claim
  // 1 -> Actual > Claim
  // -------------------------
  const sellCase = repeatArray(nSeller, (i) =>
    sellActual[i] <= claimSell[i] ? "0" : "1"
  );

  const buyCase = repeatArray(nBuyer, (j) =>
    buyActual[j] <= claimBuy[j] ? "0" : "1"
  );

  // -------------------------
  // settlement values
  // -------------------------
  const payToSeller = repeatArray(nSeller, (i) => sellActual[i] * price);
  const buyerPay = repeatArray(nBuyer, (j) => buyActual[j] * price);

  const sellerSum = sumBigInt(payToSeller);
  const buyerSum = sumBigInt(buyerPay);
  const dsoDiff = sellerSum - buyerSum;

  let balDSOAbs;
  let balDSOSign;

  if (dsoDiff > 0n) {
    balDSOSign = 1n; // DSO pays
    balDSOAbs = dsoDiff;
  } else if (dsoDiff < 0n) {
    balDSOSign = 0n; // DSO receives
    balDSOAbs = -dsoDiff;
  } else {
    balDSOSign = 0n;
    balDSOAbs = 0n;
  }

  const input = {
    // public inputs
    epoch: epoch.toString(),
    H_price_epoch,
    mClaimSell,
    mClaimBuy,
    mActualSell,
    mActualBuy,
    sellCase,
    buyCase,
    payToSeller: bigIntArrayToString(payToSeller),
    balDSOAbs: balDSOAbs.toString(),
    balDSOSign: balDSOSign.toString(),

    // private witness
    price: price.toString(),
    rPrice: rPrice.toString(),
    saltPrice: saltPrice.toString(),

    offerId: bigIntArrayToString(offerId),
    claimSell: bigIntArrayToString(claimSell),
    tSellClaim: bigIntArrayToString(tSellClaim),
    saltClaimSell: bigIntArrayToString(saltClaimSell),

    sellMeterId: bigIntArrayToString(sellMeterId),
    sellActual: bigIntArrayToString(sellActual),
    tSellActual: bigIntArrayToString(tSellActual),
    saltSell: bigIntArrayToString(saltSell),

    orderId: bigIntArrayToString(orderId),
    claimBuy: bigIntArrayToString(claimBuy),
    tBuyClaim: bigIntArrayToString(tBuyClaim),
    saltClaimBuy: bigIntArrayToString(saltClaimBuy),

    buyMeterId: bigIntArrayToString(buyMeterId),
    buyActual: bigIntArrayToString(buyActual),
    tBuyActual: bigIntArrayToString(tBuyActual),
    saltBuy: bigIntArrayToString(saltBuy),
  };

  const outDir = path.join(
    "inputs",
    "generated",
    "experiment",
    `${nSeller}_${nBuyer}_${mode}`
  );
  fs.mkdirSync(outDir, { recursive: true });

  const outPath = path.join(outDir, "input.json");
  fs.writeFileSync(outPath, JSON.stringify(input, null, 2));

  console.log(`Experiment input generated`);
  console.log(`nSeller = ${nSeller}`);
  console.log(`nBuyer  = ${nBuyer}`);
  console.log(`mode    = ${mode}`);
  console.log(`epoch   = ${epoch}`);
  console.log(`price   = ${price}`);
  console.log(`sellerSum = ${sellerSum.toString()}`);
  console.log(`buyerSum  = ${buyerSum.toString()}`);
  console.log(`balDSOAbs = ${balDSOAbs.toString()}`);
  console.log(`balDSOSign = ${balDSOSign.toString()}`);
  console.log(`Output: ${outPath}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});


