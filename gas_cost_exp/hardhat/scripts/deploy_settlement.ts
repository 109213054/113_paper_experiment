import hre from "hardhat";

async function main() {
  const connection = await hre.network.connect();

  const settlement = await connection.viem.deployContract("Settlement", []);
  console.log("Settlement deployed at:", settlement.address);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
