const fs = require("fs");
const path = require("path");
const circomlibjs = require("circomlibjs");

async function main() {
  const mode = process.argv[2] || "receive"; // receive / pay / zero / classify1 / classify2

  const poseidon = await circomlibjs.buildPoseidon();
  const F = poseidon.F;

  // -------------------------
  // epoch
  // -------------------------
  const epoch = 1n;

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
  const price = 10n;
  const rPrice = 123n;
  const saltPrice = 456n;

  // -------------------------
  // IDs and timestamps
  // -------------------------
  const offerId = [1001n];
  const orderId = [2001n];

  const sellMeterId = [3001n];
  const buyMeterId = [4001n];

  const tSellClaim = [10001n];
  const tBuyClaim = [10002n];
  const tSellActual = [10011n];
  const tBuyActual = [10012n];

  // -------------------------
  // claim / actual values
  // -------------------------
  let claimSell, sellActual, claimBuy, buyActual;

  if (mode === "receive") {
    claimSell = [6n];
    sellActual = [5n]; // sellCase = 0
    claimBuy = [8n];
    buyActual = [8n];  // buyCase = 0
  } else if (mode === "pay") {
    claimSell = [10n];
    sellActual = [9n]; // sellCase = 0
    claimBuy = [5n];
    buyActual = [4n];  // buyCase = 0
  } else if (mode === "zero") {
    claimSell = [5n];
    sellActual = [5n];
    claimBuy = [5n];
    buyActual = [5n];
  } else if (mode === "classify1") {
    claimSell = [7n];
    sellActual = [9n]; // sellCase = 1
    claimBuy = [8n];
    buyActual = [8n];  // buyCase = 0
  } else if (mode === "classify2") {
    claimSell = [9n];
    sellActual = [9n]; // sellCase = 0
    claimBuy = [5n];
    buyActual = [7n];  // buyCase = 1
  } else {
    throw new Error(`Unknown mode: ${mode}`);
  }

  const saltClaimSell = [202n];
  const saltSell = [222n];
  const saltClaimBuy = [404n];
  const saltBuy = [444n];

  // -------------------------
  // commitments
  // -------------------------
  const H_price_epoch = F.toString(
    poseidon([PRICE, epoch, price, rPrice, saltPrice])
  );

  const mClaimSell = [
    F.toString(
      poseidon([
        CLAIMSELL,
        epoch,
        offerId[0],
        claimSell[0],
        tSellClaim[0],
        saltClaimSell[0]
      ])
    )
  ];

  const mClaimBuy = [
    F.toString(
      poseidon([
        CLAIMBUY,
        epoch,
        orderId[0],
        claimBuy[0],
        tBuyClaim[0],
        saltClaimBuy[0]
      ])
    )
  ];

  const mActualSell = [
    F.toString(
      poseidon([
        ACTSELL,
        epoch,
        offerId[0],
        sellMeterId[0],
        sellActual[0],
        tSellActual[0],
        saltSell[0]
      ])
    )
  ];

  const mActualBuy = [
    F.toString(
      poseidon([
        ACTBUY,
        epoch,
        orderId[0],
        buyMeterId[0],
        buyActual[0],
        tBuyActual[0],
        saltBuy[0]
      ])
    )
  ];

  // -------------------------
  // classification bits
  // -------------------------
  const sellCase = [
    sellActual[0] <= claimSell[0] ? "0" : "1"
  ];

  const buyCase = [
    buyActual[0] <= claimBuy[0] ? "0" : "1"
  ];

  // -------------------------
  // settlement values
  // -------------------------
  const payToSeller = [sellActual[0] * price];
  const buyerPay = [buyActual[0] * price];

  const sellerSum = payToSeller[0];
  const buyerSum = buyerPay[0];
  const dsoDiff = sellerSum - buyerSum;

  let balDSOAbs;
  let balDSOSign;

  if (dsoDiff > 0n) {
    balDSOSign = 1n;
    balDSOAbs = dsoDiff;
  } else if (dsoDiff < 0n) {
    balDSOSign = 0n;
    balDSOAbs = -dsoDiff;
  } else {
    balDSOSign = 0n;
    balDSOAbs = 0n;
  }

  const input = {
    // public inputs
    epoch: epoch.toString(),
    H_price_epoch,
    mClaimSell: mClaimSell.map(String),
    mClaimBuy: mClaimBuy.map(String),
    mActualSell: mActualSell.map(String),
    mActualBuy: mActualBuy.map(String),
    sellCase,
    buyCase,
    payToSeller: payToSeller.map((x) => x.toString()),
    balDSOAbs: balDSOAbs.toString(),
    balDSOSign: balDSOSign.toString(),

    // private witness
    price: price.toString(),
    rPrice: rPrice.toString(),
    saltPrice: saltPrice.toString(),

    offerId: offerId.map((x) => x.toString()),
    claimSell: claimSell.map((x) => x.toString()),
    tSellClaim: tSellClaim.map((x) => x.toString()),
    saltClaimSell: saltClaimSell.map((x) => x.toString()),

    sellMeterId: sellMeterId.map((x) => x.toString()),
    sellActual: sellActual.map((x) => x.toString()),
    tSellActual: tSellActual.map((x) => x.toString()),
    saltSell: saltSell.map((x) => x.toString()),

    orderId: orderId.map((x) => x.toString()),
    claimBuy: claimBuy.map((x) => x.toString()),
    tBuyClaim: tBuyClaim.map((x) => x.toString()),
    saltClaimBuy: saltClaimBuy.map((x) => x.toString()),

    buyMeterId: buyMeterId.map((x) => x.toString()),
    buyActual: buyActual.map((x) => x.toString()),
    tBuyActual: tBuyActual.map((x) => x.toString()),
    saltBuy: saltBuy.map((x) => x.toString())
  };

  const outDir = path.join("inputs", "generated", `phase3_msgfmt_1_1_${mode}`);
  fs.mkdirSync(outDir, { recursive: true });

  const outPath = path.join(outDir, "input.json");
  fs.writeFileSync(outPath, JSON.stringify(input, null, 2));

  console.log(`Mode: ${mode}`);
  console.log(`Input written to ${outPath}`);
  console.log(JSON.stringify(input, null, 2));
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});

