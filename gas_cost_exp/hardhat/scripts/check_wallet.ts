import hre from "hardhat";

async function main() {
  console.log("Hardhat network name:", hre.network.name);

  const connection = await hre.network.connect();
  const walletClients = await connection.viem.getWalletClients();

  console.log("Wallet client count:", walletClients.length);

  if (walletClients.length === 0) {
    throw new Error("No wallet clients found. Check PRIVATE_KEY in .env");
  }

  const wallet = walletClients[0];
  console.log("Deployer address:", wallet.account.address);

  const publicClient = await connection.viem.getPublicClient();
  const balance = await publicClient.getBalance({
    address: wallet.account.address,
  });

  console.log("Balance (wei):", balance.toString());
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
