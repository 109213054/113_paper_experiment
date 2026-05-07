const fs = require("fs");
const path = require("path");

function parsePositiveInt(value, name) {
  const n = Number.parseInt(value, 10);
  if (!Number.isInteger(n) || n <= 0) {
    throw new Error(`${name} must be a positive integer, got: ${value}`);
  }
  return n;
}

function main() {
  const nSeller = parsePositiveInt(process.argv[2] || "", "nSeller");
  const nBuyer = parsePositiveInt(process.argv[3] || "", "nBuyer");

  const outDir = path.join("circuits", "main", "generated");
  fs.mkdirSync(outDir, { recursive: true });

  const filename = `settlement_${nSeller}_${nBuyer}.circom`;
  const outPath = path.join(outDir, filename);

  const content = `pragma circom 2.1.6;

include "../../settlement.circom";

component main {public [
  epoch,
  H_price_epoch,
  mClaimSell,
  mClaimBuy,
  mActualSell,
  mActualBuy,
  sellCase,
  buyCase,
  payToSeller,
  balDSOAbs,
  balDSOSign
]} = Settlement(${nSeller}, ${nBuyer});
`;

  fs.writeFileSync(outPath, content, "utf8");

  console.log(`Generated main circuit: ${outPath}`);
  console.log(`nSeller = ${nSeller}`);
  console.log(`nBuyer  = ${nBuyer}`);
}

try {
  main();
} catch (err) {
  console.error(err.message);
  process.exit(1);
}
