import hre from "hardhat";
import { getContract } from "viem";

async function main() {
  const settlementAddress = process.env.SETTLEMENT_ADDRESS;
  const verifierAddress = process.env.VERIFIER_ADDRESS;

  if (!settlementAddress) {
    throw new Error("Missing SETTLEMENT_ADDRESS in .env");
  }

  const connection = await hre.network.connect();
  const publicClient = await connection.viem.getPublicClient();

  const settlement = getContract({
    address: settlementAddress as `0x${string}`,
    abi: [
      {
        type: "function",
        name: "verifier",
        stateMutability: "view",
        inputs: [],
        outputs: [{ type: "address" }],
      },
      {
        type: "function",
        name: "owner",
        stateMutability: "view",
        inputs: [],
        outputs: [{ type: "address" }],
      },
    ],
    client: {
      public: publicClient,
    },
  });

  const boundVerifier = await settlement.read.verifier();
  const owner = await settlement.read.owner();

  console.log("SETTLEMENT_ADDRESS from .env =", settlementAddress);
  console.log("VERIFIER_ADDRESS   from .env =", verifierAddress || "");
  console.log("Verifier bound inside Settlement =", boundVerifier);
  console.log("Owner =", owner);
  console.log(
    "Binding matches env verifier =",
    verifierAddress
      ? boundVerifier.toLowerCase() === verifierAddress.toLowerCase()
      : false
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
