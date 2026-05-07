import fs from "fs";
import path from "path";
import hre from "hardhat";

function upsertEnvLine(envPath: string, key: string, value: string) {
  let content = "";
  if (fs.existsSync(envPath)) {
    content = fs.readFileSync(envPath, "utf8");
  }

  const line = `${key}=${value}`;
  const regex = new RegExp(`^${key}=.*$`, "m");

  if (regex.test(content)) {
    content = content.replace(regex, line);
  } else {
    if (content.length > 0 && !content.endsWith("\n")) {
      content += "\n";
    }
    content += line + "\n";
  }

  fs.writeFileSync(envPath, content);
}

function ensureDir(dirPath: string) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function loadArtifactFromFqn(fqn: string) {
  const [sourceName, contractName] = fqn.split(":");
  if (!sourceName || !contractName) {
    throw new Error(`Invalid FQN: ${fqn}`);
  }

  const artifactPath = path.resolve("artifacts", sourceName, `${contractName}.json`);
  if (!fs.existsSync(artifactPath)) {
    throw new Error(`Artifact not found: ${artifactPath}`);
  }

  return JSON.parse(fs.readFileSync(artifactPath, "utf8"));
}

function loadArtifactByPath(...parts: string[]) {
  const artifactPath = path.resolve("artifacts", ...parts);
  if (!fs.existsSync(artifactPath)) {
    throw new Error(`Artifact not found: ${artifactPath}`);
  }
  return JSON.parse(fs.readFileSync(artifactPath, "utf8"));
}

function getSettlementConfig(caseTag: string) {
  switch (caseTag) {
    case "s1_b10":
      return {
        contractName: "SettlementBench_s1_b10",
        artifact: loadArtifactByPath(
          "contracts",
          "settlement",
          "SettlementBench_s1_b10.sol",
          "SettlementBench_s1_b10.json"
        ),
      };
    case "s1_b20":
      return {
        contractName: "SettlementBench_s1_b20",
        artifact: loadArtifactByPath(
          "contracts",
          "settlement",
          "SettlementBench_s1_b20.sol",
          "SettlementBench_s1_b20.json"
        ),
      };
    case "s1_b30":
      return {
        contractName: "SettlementBench_s1_b30",
        artifact: loadArtifactByPath(
          "contracts",
          "settlement",
          "SettlementBench_s1_b30.sol",
          "SettlementBench_s1_b30.json"
        ),
      };
    case "s1_b40":
      return {
        contractName: "SettlementBench_s1_b40",
        artifact: loadArtifactByPath(
          "contracts",
          "settlement",
          "SettlementBench_s1_b40.sol",
          "SettlementBench_s1_b40.json"
        ),
      };
    default:
      throw new Error(`Unsupported CASE_TAG: ${caseTag}`);
  }
}

async function main() {
  const caseTag = process.env.CASE_TAG || "s1_b10";
  const verifierFqn =
    process.env.VERIFIER_FQN ||
    "contracts/verifiers/Verifier_s1_b10.sol:Groth16Verifier";
  const envPath = path.resolve(".env");
  const resultDir = process.env.RESULT_DIR || "../results/raw/kurtosis";

  const settlementConfig = getSettlementConfig(caseTag);
  const settlementContractName = settlementConfig.contractName;
  const settlementArtifact = settlementConfig.artifact;

  console.log("Using case:", caseTag);
  console.log("Using verifier:", verifierFqn);
  console.log("Using settlement:", settlementContractName);

  const connection = await hre.network.connect();
  const publicClient = await connection.viem.getPublicClient();
  const walletClients = await connection.viem.getWalletClients();
  const wallet = walletClients[0];

  const verifierArtifact = loadArtifactFromFqn(verifierFqn);

  const verifierTxHash = await wallet.deployContract({
    abi: verifierArtifact.abi,
    bytecode: verifierArtifact.bytecode as `0x${string}`,
    args: [],
  });
  console.log("Verifier deployment tx:", verifierTxHash);

  const verifierReceipt = await publicClient.waitForTransactionReceipt({
    hash: verifierTxHash,
  });
  const verifierAddress = verifierReceipt.contractAddress;
  if (!verifierAddress) {
    throw new Error("Verifier deployment receipt missing contractAddress");
  }
  console.log("Verifier deployed at:", verifierAddress);

  const settlementTxHash = await wallet.deployContract({
    abi: settlementArtifact.abi,
    bytecode: settlementArtifact.bytecode as `0x${string}`,
    args: [verifierAddress],
  });
  console.log("Settlement deployment tx:", settlementTxHash);

  const settlementReceipt = await publicClient.waitForTransactionReceipt({
    hash: settlementTxHash,
  });
  const settlementAddress = settlementReceipt.contractAddress;
  if (!settlementAddress) {
    throw new Error("Settlement deployment receipt missing contractAddress");
  }
  console.log("Settlement deployed at:", settlementAddress);

  upsertEnvLine(envPath, "VERIFIER_ADDRESS", verifierAddress);
  upsertEnvLine(envPath, "SETTLEMENT_ADDRESS", settlementAddress);

  ensureDir(resultDir);

  const verifierOut = path.join(resultDir, `gas_deploy_verifier_${caseTag}.json`);
  const settlementOut = path.join(resultDir, `gas_deploy_settlement_${caseTag}.json`);

  fs.writeFileSync(
    verifierOut,
    JSON.stringify(
      {
        metric: "Gas_deploy_verifier",
        network: "kurtosis",
        caseTag,
        nSeller: Number(process.env.N_SELLER || "1"),
        nBuyer: Number(process.env.N_BUYER || "10"),
        verifierAddress,
        txHash: verifierTxHash,
        gasUsed: verifierReceipt.gasUsed.toString(),
        verifierFqn,
      },
      null,
      2
    )
  );

  fs.writeFileSync(
    settlementOut,
    JSON.stringify(
      {
        metric: "Gas_deploy_settlement",
        network: "kurtosis",
        caseTag,
        nSeller: Number(process.env.N_SELLER || "1"),
        nBuyer: Number(process.env.N_BUYER || "10"),
        settlementAddress,
        verifierAddress,
        settlementContractName,
        txHash: settlementTxHash,
        gasUsed: settlementReceipt.gasUsed.toString(),
      },
      null,
      2
    )
  );

  console.log("Updated .env with deployed addresses.");
  console.log("Saved deployment gas results.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
