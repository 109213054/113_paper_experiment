const fs = require("fs");
const path = require("path");
const circomlibjs = require("circomlibjs");

async function main() {
  const poseidon = await circomlibjs.buildPoseidon();
  const F = poseidon.F;

  // price commitment witness
  const price = 10n;
  const rPrice = 123n;
  const saltPrice = 456n;

  // seller witness
  const sid = [1n];
  const sellActual = [5n];
  const rSell = [111n];
  const saltSell = [222n];

  // buyer witness
  const bid = [1n];
  const buyActual = [8n];
  const rBuy = [333n];
  const saltBuy = [444n];

  // public outputs derived from witness
  const H_price_epoch = F.toString(
    poseidon([price, rPrice, saltPrice])
  );

  const mActualSell = [
    F.toString(
      poseidon([sid[0], sellActual[0], rSell[0], saltSell[0]])
    )
  ];

  const mActualBuy = [
    F.toString(
      poseidon([bid[0], buyActual[0], rBuy[0], saltBuy[0]])
    )
  ];

  const payToSeller = [sellActual[0] * price];
  const buyerPay = [buyActual[0] * price];
  const balDSOAbs = buyerPay[0] - payToSeller[0];

  const input = {
    // public inputs
    H_price_epoch,
    mActualSell: mActualSell.map(String),
    mActualBuy: mActualBuy.map(String),
    payToSeller: payToSeller.map((x) => x.toString()),
    balDSOAbs: balDSOAbs.toString(),

    // private witness
    price: price.toString(),
    rPrice: rPrice.toString(),
    saltPrice: saltPrice.toString(),

    sid: sid.map((x) => x.toString()),
    sellActual: sellActual.map((x) => x.toString()),
    rSell: rSell.map((x) => x.toString()),
    saltSell: saltSell.map((x) => x.toString()),

    bid: bid.map((x) => x.toString()),
    buyActual: buyActual.map((x) => x.toString()),
    rBuy: rBuy.map((x) => x.toString()),
    saltBuy: saltBuy.map((x) => x.toString())
  };

  const outDir = path.join("inputs", "generated", "formal_1_1");
  fs.mkdirSync(outDir, { recursive: true });

  const outPath = path.join(outDir, "input.json");
  fs.writeFileSync(outPath, JSON.stringify(input, null, 2));

  console.log(`Input written to ${outPath}`);
  console.log(JSON.stringify(input, null, 2));
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});


