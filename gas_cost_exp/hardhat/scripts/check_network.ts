import hre from "hardhat";

async function main() {
  console.log("Hardhat network name:", hre.network.name);

  const client = await hre.network.connect();

  console.log("Connected successfully.");
  console.log("Network config loaded.");
  console.log(client);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
