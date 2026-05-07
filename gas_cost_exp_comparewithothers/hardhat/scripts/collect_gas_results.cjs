const fs = require("fs");
const path = require("path");

const rawDir = path.resolve(__dirname, "../../results/raw/kurtosis");
const outDir = path.resolve(__dirname, "../../results/processed");
const outCsv = path.join(outDir, "gas_summary_comparewithothers.csv");

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function csvEscape(value) {
  if (value === null || value === undefined) return "";
  const str = String(value);
  if (str.includes(",") || str.includes('"') || str.includes("\n")) {
    return `"${str.replace(/"/g, '""')}"`;
  }
  return str;
}

function main() {
  ensureDir(outDir);

  if (!fs.existsSync(rawDir)) {
    throw new Error(`Raw result directory does not exist: ${rawDir}`);
  }

  const files = fs
    .readdirSync(rawDir)
    .filter((name) => name.endsWith(".json"))
    .sort();

  const rows = [];

  for (const file of files) {
    const fullPath = path.join(rawDir, file);
    const obj = JSON.parse(fs.readFileSync(fullPath, "utf8"));
    obj.sourceFile = file;
    rows.push(obj);
  }

  const columns = [
    "metric",
    "network",
    "caseTag",
    "nSeller",
    "nBuyer",
    "gasUsed",
    "adjustedExecutionGasApprox",
    "intrinsicGas",
    "calldataGasApprox",
    "settlementAddress",
    "verifierAddress",
    "txHash",
    "proofPath",
    "publicPath",
    "publicSignalLength",
    "expectedDirectVerify",
    "expectedSettlementSimulate",
    "payoutAmountWei",
    "recipient",
    "emittedAmount",
    "verifyMode",
    "payoutMode",
    "settlementContractName",
    "verifierFqn",
    "sourceFile",
  ];

  const lines = [
    columns.join(","),
    ...rows.map((row) =>
      columns.map((col) => csvEscape(row[col])).join(",")
    ),
  ];

  fs.writeFileSync(outCsv, lines.join("\n"));
  console.log(`Saved CSV to: ${outCsv}`);
  console.log(`Included ${rows.length} result file(s).`);
}

try {
  main();
} catch (err) {
  console.error(err);
  process.exit(1);
}
