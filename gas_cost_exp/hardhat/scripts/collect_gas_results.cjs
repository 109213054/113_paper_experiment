const fs = require("fs");
const path = require("path");

const RAW_DIR = path.resolve(__dirname, "../../results/raw/kurtosis");
const OUT_DIR = path.resolve(__dirname, "../../results/processed");
const OUT_CSV = path.join(OUT_DIR, "gas_summary.csv");

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function toCsvRow(values) {
  return values
    .map((v) => {
      const s = String(v ?? "");
      if (s.includes(",") || s.includes('"') || s.includes("\n")) {
        return `"${s.replace(/"/g, '""')}"`;
      }
      return s;
    })
    .join(",");
}

function main() {
  if (!fs.existsSync(RAW_DIR)) {
    throw new Error(`Raw result directory not found: ${RAW_DIR}`);
  }

  const files = fs
    .readdirSync(RAW_DIR)
    .filter((f) => f.endsWith(".json"))
    .sort();

  if (files.length === 0) {
    throw new Error(`No JSON result files found in: ${RAW_DIR}`);
  }

  const rows = [];

  for (const file of files) {
    const fullPath = path.join(RAW_DIR, file);
    const data = readJson(fullPath);

    rows.push({
      metric: data.metric || "",
      network: data.network || "",
      experimentN: data.experimentN || "",
      gasUsed: data.gasUsed || "",
      settlementAddress: data.settlementAddress || "",
      verifierAddress: data.verifierAddress || "",
      txHash: data.txHash || "",
      proofPath: data.proofPath || "",
      publicPath: data.publicPath || "",
      expectedDirectVerify:
        data.expectedDirectVerify !== undefined ? data.expectedDirectVerify : "",
      expectedSettlementSimulate:
        data.expectedSettlementSimulate !== undefined
          ? data.expectedSettlementSimulate
          : "",
      eventOk: data.eventOk !== undefined ? data.eventOk : "",
      roundId: data.roundId || "",
      emittedRoundId: data.emittedRoundId || "",
      sourceFile: file,
    });
  }

  ensureDir(OUT_DIR);

  const header = [
    "metric",
    "network",
    "experimentN",
    "gasUsed",
    "settlementAddress",
    "verifierAddress",
    "txHash",
    "proofPath",
    "publicPath",
    "expectedDirectVerify",
    "expectedSettlementSimulate",
    "eventOk",
    "roundId",
    "emittedRoundId",
    "sourceFile",
  ];

  const lines = [toCsvRow(header)];

  for (const row of rows) {
    lines.push(
      toCsvRow([
        row.metric,
        row.network,
        row.experimentN,
        row.gasUsed,
        row.settlementAddress,
        row.verifierAddress,
        row.txHash,
        row.proofPath,
        row.publicPath,
        row.expectedDirectVerify,
        row.expectedSettlementSimulate,
        row.eventOk,
        row.roundId,
        row.emittedRoundId,
        row.sourceFile,
      ])
    );
  }

  fs.writeFileSync(OUT_CSV, lines.join("\n") + "\n");
  console.log(`Saved CSV to: ${OUT_CSV}`);
  console.log(`Included ${rows.length} result file(s).`);
}

try {
  main();
} catch (err) {
  console.error(err.message);
  process.exit(1);
}
