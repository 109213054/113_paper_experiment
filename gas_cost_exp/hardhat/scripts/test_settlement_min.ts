import hre from "hardhat";
import { getContract } from "viem";

async function main() {
  const contractAddress = process.env.SETTLEMENT_ADDRESS;

  if (!contractAddress) {
    throw new Error(
      "Missing SETTLEMENT_ADDRESS. Example: SETTLEMENT_ADDRESS=0x... npx hardhat run scripts/test_settlement_min.ts --network kurtosis"
    );
  }

  const connection = await hre.network.connect();
  const walletClients = await connection.viem.getWalletClients();
  const wallet = walletClients[0];
  const publicClient = await connection.viem.getPublicClient();

  const code = await publicClient.getCode({
    address: contractAddress as `0x${string}`,
  });

  if (!code || code === "0x") {
    throw new Error(`No contract code found at ${contractAddress}`);
  }

  console.log("Settlement address:", contractAddress);
  console.log("Contract exists on chain.");

  const contract = getContract({
    address: contractAddress as `0x${string}`,
    abi: [
      {
        type: "function",
        name: "verifyBillOnly",
        stateMutability: "pure",
        inputs: [],
        outputs: [{ type: "bool" }],
      },
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

  const ok = await contract.read.verifyBillOnly();
  console.log("verifyBillOnly() =", ok);

  const txHash = await contract.write.settle([1n]);
  console.log("settle tx hash =", txHash);

  const receipt = await publicClient.waitForTransactionReceipt({ hash: txHash });
  console.log("gasUsed =", receipt.gasUsed.toString());
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
