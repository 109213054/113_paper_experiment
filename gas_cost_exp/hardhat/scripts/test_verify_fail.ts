import fs from "fs";
import path from "path";
import hre from "hardhat";
import { decodeEventLog, getContract, parseAbiItem } from "viem";

function loadJson(filePath: string) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function ensureDir(dirPath: string) {
  fs.mkdirSync(dirPath, { recursive: true });
}

async function main() {
  const settlementAddress = process.env.SETTLEMENT_ADDRESS;
  const verifierAddress = process.env.VERIFIER_ADDRESS || "";
  const experimentN = process.env.EXPERIMENT_N || "10";
  const proofPath =
    process.env.PROOF_PATH || `../zkp/proofs/n_${experimentN}/proof.json`;
  const publicPath =
    process.env.PUBLIC_FAIL_PATH || `../zkp/proofs/n_${experimentN}/public_fail.json`;
  const resultDir = process.env.RESULT_DIR || "../results/raw/kurtosis";

  if (!settlementAddress) {
    throw new Error("Missing SETTLEMENT_ADDRESS in .env");
  }

  const proof = loadJson(proofPath);
  const publicSignals = loadJson(publicPath);

  const pA: [bigint, bigint] = [
    BigInt(proof.pi_a[0]),
    BigInt(proof.pi_a[1]),
  ];

  const pB: [[bigint, bigint], [bigint, bigint]] = [
    [BigInt(proof.pi_b[0][1]), BigInt(proof.pi_b[0][0])],
    [BigInt(proof.pi_b[1][1]), BigInt(proof.pi_b[1][0])],
  ];

  const pC: [bigint, bigint] = [
    BigInt(proof.pi_c[0]),
    BigInt(proof.pi_c[1]),
  ];

  const pubSignals: bigint[] = publicSignals.map((x: string) => BigInt(x));

  const connection = await hre.network.connect();
  const walletClients = await connection.viem.getWalletClients();
  const wallet = walletClients[0];
  const publicClient = await connection.viem.getPublicClient();

  const contract = getContract({
    address: settlementAddress as `0x${string}`,
    abi: [
      {
        type: "function",
        name: "verifyBillOnly",
        stateMutability: "nonpayable",
        inputs: [
          { name: "pA", type: "uint256[2]" },
          { name: "pB", type: "uint256[2][2]" },
          { name: "pC", type: "uint256[2]" },
          { name: "pubSignals", type: "uint256[74]" },
        ],
        outputs: [{ type: "bool" }],
      },
    ],
    client: {
      public: publicClient,
      wallet,
    },
  });

  console.log("Settlement address:", settlementAddress);
  console.log("Proof path:", proofPath);
  console.log("Fail public path:", publicPath);

  const txHash = await contract.write.verifyBillOnly([pA, pB, pC, pubSignals]);
  console.log("verifyBillOnly tx hash =", txHash);

  const receipt = await publicClient.waitForTransactionReceipt({ hash: txHash });
  console.log("gasUsed =", receipt.gasUsed.toString());

  const eventAbi = parseAbiItem(
    "event BillVerified(address indexed caller, bool indexed ok)"
  );

  let okValue: boolean | null = null;
  for (const log of receipt.logs) {
    try {
      const decoded = decodeEventLog({
        abi: [eventAbi],
        data: log.data,
        topics: log.topics,
      });
      if (decoded.eventName === "BillVerified") {
        okValue = decoded.args.ok as boolean;
        console.log("BillVerified ok =", okValue);
      }
    } catch {
      // ignore unrelated logs
    }
  }

  ensureDir(resultDir);

  const result = {
    metric: "Gas_verify_fail",
    network: "kurtosis",
    experimentN: Number(experimentN),
    settlementAddress,
    verifierAddress,
    proofPath,
    publicPath,
    txHash,
    gasUsed: receipt.gasUsed.toString(),
    expectedDirectVerify: false,
    expectedSettlementSimulate: false,
    eventOk: okValue,
  };

  const outputPath = path.join(resultDir, `gas_verify_fail_n${experimentN}.json`);
  fs.writeFileSync(outputPath, JSON.stringify(result, null, 2));
  console.log("Saved result to:", outputPath);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
