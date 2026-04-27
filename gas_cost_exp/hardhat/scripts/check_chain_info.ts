import { createPublicClient, http } from "viem";
import hre from "hardhat";

async function main() {
  const networkName = hre.network.name;
  console.log("Network:", networkName);

  const rpcUrl = process.env.RPC_URL;
  if (!rpcUrl) {
    throw new Error("RPC_URL is missing in .env");
  }

  const client = createPublicClient({
    transport: http(rpcUrl),
  });

  const chainId = await client.getChainId();
  const blockNumber = await client.getBlockNumber();

  console.log("RPC_URL:", rpcUrl);
  console.log("Chain ID:", chainId);
  console.log("Latest block number:", blockNumber.toString());
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
