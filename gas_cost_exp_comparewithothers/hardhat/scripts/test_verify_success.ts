import fs from "fs";
import path from "path";
import hre from "hardhat";
import { encodeFunctionData, getContract } from "viem";

function loadJson(filePath: string) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function ensureDir(dirPath: string) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function estimateCalldataGas(hexData: string): number {
  const data = hexData.startsWith("0x") ? hexData.slice(2) : hexData;
  let gas = 0;
  for (let i = 0; i < data.length; i += 2) {
    const byteHex = data.slice(i, i + 2);
    gas += byteHex === "00" ? 4 : 16;
  }
  return gas;
}

async function main() {
  const settlementAddress = process.env.SETTLEMENT_ADDRESS;
  const verifierAddress = process.env.VERIFIER_ADDRESS || "";
  const caseTag = process.env.CASE_TAG || "s1_b10";
  const nSeller = Number(process.env.N_SELLER || "1");
  const nBuyer = Number(process.env.N_BUYER || "10");
  const proofPath = process.env.PROOF_PATH || `../zkp/proofs/${caseTag}/proof.json`;
  const publicPath = process.env.PUBLIC_PATH || `../zkp/proofs/${caseTag}/public.json`;
  const resultDir = process.env.RESULT_DIR || "../results/raw/kurtosis";

  if (!settlementAddress) {
    throw new Error("Missing SETTLEMENT_ADDRESS in .env");
  }

  const proof = loadJson(proofPath);
  const publicSignals = loadJson(publicPath);
  const pubSignalsLength = publicSignals.length;

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

  const dynamicAbi = [
    {
      type: "function",
      name: "benchmarkVerifyOnly",
      stateMutability: "nonpayable",
      inputs: [
        { name: "pA", type: "uint256[2]" },
        { name: "pB", type: "uint256[2][2]" },
        { name: "pC", type: "uint256[2]" },
        { name: "pubSignals", type: `uint256[${pubSignalsLength}]` },
      ],
      outputs: [{ type: "bool" }],
    },
  ] as const;

  const contract = getContract({
    address: settlementAddress as `0x${string}`,
    abi: dynamicAbi,
    client: {
      public: publicClient,
      wallet,
    },
  });

  const calldata = encodeFunctionData({
    abi: dynamicAbi,
    functionName: "benchmarkVerifyOnly",
    args: [pA, pB, pC, pubSignals],
  });

  const calldataGasApprox = estimateCalldataGas(calldata);
  const intrinsicGas = 21000;

  console.log("Case:", caseTag);
  console.log("Settlement address:", settlementAddress);
  console.log("Proof path:", proofPath);
  console.log("Public path:", publicPath);
  console.log("Public signal length:", pubSignalsLength);

  const txHash = await contract.write.benchmarkVerifyOnly([pA, pB, pC, pubSignals]);
  console.log("benchmarkVerifyOnly tx hash =", txHash);

  const receipt = await publicClient.waitForTransactionReceipt({ hash: txHash });
  const rawGasUsed = Number(receipt.gasUsed);
  const adjustedExecutionGasApprox = rawGasUsed - intrinsicGas - calldataGasApprox;

  console.log("raw gasUsed =", rawGasUsed);
  console.log("intrinsicGas =", intrinsicGas);
  console.log("calldataGasApprox =", calldataGasApprox);
  console.log("adjustedExecutionGasApprox =", adjustedExecutionGasApprox);

  ensureDir(resultDir);

  const result = {
    metric: "Gas_verify_success",
    network: "kurtosis",
    caseTag,
    nSeller,
    nBuyer,
    settlementAddress,
    verifierAddress,
    proofPath,
    publicPath,
    publicSignalLength: pubSignalsLength,
    txHash,
    gasUsed: String(rawGasUsed),
    intrinsicGas,
    calldataGasApprox,
    adjustedExecutionGasApprox,
    verifyMode: "benchmarkVerifyOnly",
    expectedDirectVerify: true,
    expectedSettlementSimulate: true,
  };

  const outputPath = path.join(resultDir, `gas_verify_success_${caseTag}.json`);
  fs.writeFileSync(outputPath, JSON.stringify(result, null, 2));
  console.log("Saved result to:", outputPath);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
