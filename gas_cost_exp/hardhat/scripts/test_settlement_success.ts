import fs from "fs";
import path from "path";
import hre from "hardhat";
import { decodeEventLog, getContract, parseAbiItem } from "viem";

function ensureDir(dirPath: string) {
  fs.mkdirSync(dirPath, { recursive: true });
}

async function main() {
  const settlementAddress = process.env.SETTLEMENT_ADDRESS;
  const verifierAddress = process.env.VERIFIER_ADDRESS || "";
  const experimentN = process.env.EXPERIMENT_N || "10";
  const roundId = BigInt(process.env.ROUND_ID || "1");
  const resultDir = process.env.RESULT_DIR || "../results/raw/kurtosis";

  if (!settlementAddress) {
    throw new Error("Missing SETTLEMENT_ADDRESS in .env");
  }

  const connection = await hre.network.connect();
  const walletClients = await connection.viem.getWalletClients();
  const wallet = walletClients[0];
  const publicClient = await connection.viem.getPublicClient();

  const contract = getContract({
    address: settlementAddress as `0x${string}`,
    abi: [
      {
        type: "function",
        name: "settle",
        stateMutability: "nonpayable",
        inputs: [{ name: "roundId", type: "uint256" }],
        outputs: [],
      },
    ],
    client: {
      public: publicClient,
      wallet,
    },
  });

  console.log("Settlement address:", settlementAddress);
  console.log("Round ID:", roundId.toString());

  const txHash = await contract.write.settle([roundId]);
  console.log("settle tx hash =", txHash);

  const receipt = await publicClient.waitForTransactionReceipt({ hash: txHash });
  console.log("gasUsed =", receipt.gasUsed.toString());

  const eventAbi = parseAbiItem(
    "event SettlementExecuted(address indexed caller, uint256 indexed roundId)"
  );

  let emittedRoundId: string | null = null;
  for (const log of receipt.logs) {
    try {
      const decoded = decodeEventLog({
        abi: [eventAbi],
        data: log.data,
        topics: log.topics,
      });
      if (decoded.eventName === "SettlementExecuted") {
        emittedRoundId = decoded.args.roundId?.toString() || null;
        console.log("SettlementExecuted roundId =", emittedRoundId);
      }
    } catch {
      // ignore unrelated logs
    }
  }

  ensureDir(resultDir);

  const result = {
    metric: "Gas_settlement_success",
    network: "kurtosis",
    experimentN: Number(experimentN),
    settlementAddress,
    verifierAddress,
    roundId: roundId.toString(),
    txHash,
    gasUsed: receipt.gasUsed.toString(),
    emittedRoundId,
  };

  const outputPath = path.join(resultDir, `gas_settlement_success_n${experimentN}.json`);
  fs.writeFileSync(outputPath, JSON.stringify(result, null, 2));
  console.log("Saved result to:", outputPath);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
