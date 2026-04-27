import fs from "fs";
import hre from "hardhat";
import {
  decodeEventLog,
  getContract,
  parseAbiItem,
} from "viem";

function loadJson(filePath: string) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

async function main() {
  const verifierAddress = process.env.VERIFIER_ADDRESS;
  const settlementAddress = process.env.SETTLEMENT_ADDRESS;
  const experimentN = process.env.EXPERIMENT_N || "10";
  const proofPath =
    process.env.PROOF_PATH || `../zkp/proofs/n_${experimentN}/proof.json`;
  const publicPath =
    process.env.PUBLIC_PATH || `../zkp/proofs/n_${experimentN}/public.json`;

  if (!verifierAddress) throw new Error("Missing VERIFIER_ADDRESS in .env");
  if (!settlementAddress) throw new Error("Missing SETTLEMENT_ADDRESS in .env");

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

  const verifier = getContract({
    address: verifierAddress as `0x${string}`,
    abi: [
      {
        type: "function",
        name: "verifyProof",
        stateMutability: "view",
        inputs: [
          { name: "_pA", type: "uint256[2]" },
          { name: "_pB", type: "uint256[2][2]" },
          { name: "_pC", type: "uint256[2]" },
          { name: "_pubSignals", type: "uint256[74]" },
        ],
        outputs: [{ type: "bool" }],
      },
    ],
    client: { public: publicClient },
  });

  const settlement = getContract({
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
      {
        type: "function",
        name: "verifier",
        stateMutability: "view",
        inputs: [],
        outputs: [{ type: "address" }],
      },
    ],
    client: {
      public: publicClient,
      wallet,
    },
  });

  console.log("Verifier address   =", verifierAddress);
  console.log("Settlement address =", settlementAddress);
  console.log("Settlement.verifier() =", await settlement.read.verifier());
  console.log("Proof path =", proofPath);
  console.log("Public path =", publicPath);

  const directOk = await verifier.read.verifyProof([pA, pB, pC, pubSignals]);
  console.log("Direct verifier.verifyProof() =", directOk);

  const simulateResult = await publicClient.simulateContract({
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
    functionName: "verifyBillOnly",
    args: [pA, pB, pC, pubSignals],
    account: wallet.account,
  });

  console.log("Settlement simulate result =", simulateResult.result);

  const txHash = await settlement.write.verifyBillOnly([pA, pB, pC, pubSignals]);
  console.log("Settlement tx hash =", txHash);

  const receipt = await publicClient.waitForTransactionReceipt({ hash: txHash });
  console.log("Settlement tx gasUsed =", receipt.gasUsed.toString());

  const eventAbi = parseAbiItem(
    "event BillVerified(address indexed caller, bool indexed ok)"
  );

  console.log("Raw receipt logs:");
  for (const [idx, log] of receipt.logs.entries()) {
    console.log(`log[${idx}] address =`, log.address);
    console.log(`log[${idx}] topics  =`, log.topics);
    console.log(`log[${idx}] data    =`, log.data);

    try {
      const decoded = decodeEventLog({
        abi: [eventAbi],
        data: log.data,
        topics: log.topics,
      });
      console.log(`log[${idx}] decoded BillVerified ok =`, decoded.args.ok);
    } catch {
      // ignore unrelated logs
    }
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
