const fs = require("fs");
const path = require("path");
const circomlibjs = require("circomlibjs");

async function main() {
  const mode = process.argv[2] || "receive"; // receive / pay / zero

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
  // IDs
  // -------------------------
  const sid = [1n];
  const bid = [1n];

  // -------------------------
  // claim / actual energy values
  // 目前 Phase 2 先讓 claim 與 actual 相同，先把 commitment 層補齊
  // -------------------------
  let sellActual;
  let buyActual;

  if (mode === "pay") {
    sellActual = [9n];
    buyActual = [4n];
  } else if (mode === "receive") {
    sellActual = [5n];
    buyActual = [8n];
  } else if (mode === "zero") {
    sellActual = [5n];
    buyActual = [5n];
  } else {
    throw new Error(`Unknown mode: ${mode}`);
  }

  const claimSell = [...sellActual];
  const claimBuy = [...buyActual];

  const rClaimSell = [101n];
  const saltClaimSell = [202n];

  const rSell = [111n];
  const saltSell = [222n];

  const rClaimBuy = [303n];
  const saltClaimBuy = [404n];

  const rBuy = [333n];
  const saltBuy = [444n];

  // -------------------------
  // commitments
  // -------------------------
  const H_price_epoch = F.toString(
    poseidon([PRICE, epoch, price, rPrice, saltPrice])
  );

  const mClaimSell = [
    F.toString(
      poseidon([CLAIMSELL, epoch, sid[0], claimSell[0], rClaimSell[0], saltClaimSell[0]])
    )
  ];

  const mClaimBuy = [
    F.toString(
      poseidon([CLAIMBUY, epoch, bid[0], claimBuy[0], rClaimBuy[0], saltClaimBuy[0]])
    )
  ];

  const mActualSell = [
    F.toString(
      poseidon([ACTSELL, epoch, sid[0], sellActual[0], rSell[0], saltSell[0]])
    )
  ];

  const mActualBuy = [
    F.toString(
      poseidon([ACTBUY, epoch, bid[0], buyActual[0], rBuy[0], saltBuy[0]])
    )
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
    balDSOSign = 1n; // DSO 應付
    balDSOAbs = dsoDiff;
  } else if (dsoDiff < 0n) {
    balDSOSign = 0n; // DSO 應收
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
    payToSeller: payToSeller.map((x) => x.toString()),
    balDSOAbs: balDSOAbs.toString(),
    balDSOSign: balDSOSign.toString(),

    // private witness
    price: price.toString(),
    rPrice: rPrice.toString(),
    saltPrice: saltPrice.toString(),

    sid: sid.map((x) => x.toString()),
    claimSell: claimSell.map((x) => x.toString()),
    rClaimSell: rClaimSell.map((x) => x.toString()),
    saltClaimSell: saltClaimSell.map((x) => x.toString()),

    sellActual: sellActual.map((x) => x.toString()),
    rSell: rSell.map((x) => x.toString()),
    saltSell: saltSell.map((x) => x.toString()),

    bid: bid.map((x) => x.toString()),
    claimBuy: claimBuy.map((x) => x.toString()),
    rClaimBuy: rClaimBuy.map((x) => x.toString()),
    saltClaimBuy: saltClaimBuy.map((x) => x.toString()),

    buyActual: buyActual.map((x) => x.toString()),
    rBuy: rBuy.map((x) => x.toString()),
    saltBuy: saltBuy.map((x) => x.toString())
  };

  const outDir = path.join("inputs", "generated", `phase2_signed_1_1_${mode}`);
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

