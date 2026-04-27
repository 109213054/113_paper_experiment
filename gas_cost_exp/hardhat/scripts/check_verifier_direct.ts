import fs from "fs";
import hre from "hardhat";
import { getContract } from "viem";

function loadJson(filePath: string) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

async function main() {
  const verifierAddress = process.env.VERIFIER_ADDRESS;
  const experimentN = process.env.EXPERIMENT_N || "10";
  const proofPath =
    process.env.PROOF_PATH || `../zkp/proofs/n_${experimentN}/proof.json`;
  const publicPath =
    process.env.PUBLIC_PATH || `../zkp/proofs/n_${experimentN}/public.json`;

  if (!verifierAddress) {
    throw new Error("Missing VERIFIER_ADDRESS in .env");
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
    client: {
      public: publicClient,
    },
  });

  console.log("Verifier address:", verifierAddress);
  console.log("Proof path:", proofPath);
  console.log("Public path:", publicPath);

  const ok = await verifier.read.verifyProof([pA, pB, pC, pubSignals]);
  console.log("verifyProof() =", ok);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
