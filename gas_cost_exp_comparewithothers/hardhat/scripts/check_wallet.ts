import hre from "hardhat";

async function main() {
  const rpcUrl = process.env.RPC_URL || "";
  const privateKey = process.env.PRIVATE_KEY || "";

  if (!rpcUrl) {
    throw new Error("Missing RPC_URL in .env");
  }

  if (!privateKey) {
    throw new Error("Missing PRIVATE_KEY in .env");
  }

  const connection = await hre.network.connect();
  const publicClient = await connection.viem.getPublicClient();
  const walletClients = await connection.viem.getWalletClients();

  if (!walletClients || walletClients.length === 0) {
    throw new Error("No wallet client available. Check PRIVATE_KEY in .env");
  }

  const wallet = walletClients[0];
  const address = wallet.account.address;
  const balance = await publicClient.getBalance({ address });

  console.log("RPC OK");
  console.log("RPC_URL:", rpcUrl);
  console.log("Deployer address:", address);
  console.log("Balance (wei):", balance.toString());

  if (balance === 0n) {
    console.log("WARNING: balance is 0. This account may not be usable for deployment.");
  } else {
    console.log("Wallet is usable for deployment/testing.");
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
