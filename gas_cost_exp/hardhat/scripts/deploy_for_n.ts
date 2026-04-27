import hre from "hardhat";

async function main() {
  const verifierFqn =
    process.env.VERIFIER_FQN ||
    "contracts/verifiers/Verifier_n10.sol:Groth16Verifier";

  console.log("Using verifier:", verifierFqn);

  const connection = await hre.network.connect();

  const verifier = await connection.viem.deployContract(verifierFqn as any, []);
  console.log("Verifier deployed at:", verifier.address);

  const settlement = await connection.viem.deployContract("Settlement", [
    verifier.address,
  ]);
  console.log("Settlement deployed at:", settlement.address);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
