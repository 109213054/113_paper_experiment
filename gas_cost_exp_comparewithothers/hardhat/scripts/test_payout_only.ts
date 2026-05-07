import fs from "fs";
import path from "path";
import hre from "hardhat";
import { decodeEventLog, getContract, parseAbiItem, parseEther } from "viem";

function ensureDir(dirPath: string) {
  fs.mkdirSync(dirPath, { recursive: true });
}

async function main() {
  const settlementAddress = process.env.SETTLEMENT_ADDRESS;
  const verifierAddress = process.env.VERIFIER_ADDRESS || "";
  const caseTag = process.env.CASE_TAG || "s1_b10";
  const nSeller = Number(process.env.N_SELLER || "1");
  const nBuyer = Number(process.env.N_BUYER || "10");
  const payoutAmount = parseEther(process.env.PAYOUT_AMOUNT_ETH || "0.001");
  const resultDir = process.env.RESULT_DIR || "../results/raw/kurtosis";

  if (!settlementAddress) {
    throw new Error("Missing SETTLEMENT_ADDRESS in .env");
  }

  const connection = await hre.network.connect();
  const walletClients = await connection.viem.getWalletClients();
  const wallet = walletClients[0];
  const publicClient = await connection.viem.getPublicClient();

  const recipient = `0x${"1".padStart(40, "0")}` as `0x${string}`;

  const contract = getContract({
    address: settlementAddress as `0x${string}`,
    abi: [
      {
        type: "function",
        name: "deposit",
        stateMutability: "payable",
        inputs: [],
        outputs: [],
      },
      {
        type: "function",
        name: "benchmarkPayoutOnly",
        stateMutability: "nonpayable",
        inputs: [
          { name: "recipient", type: "address" },
          { name: "amount", type: "uint256" },
        ],
        outputs: [],
      },
    ],
    client: {
      public: publicClient,
      wallet,
    },
  });

  console.log("Case:", caseTag);
  console.log("Settlement address:", settlementAddress);
  console.log("Owner:", wallet.account.address);
  console.log("Recipient:", recipient);
  console.log("Payout amount (wei):", payoutAmount.toString());

  const depositTx = await contract.write.deposit([], {
    value: payoutAmount,
  });
  console.log("deposit tx hash =", depositTx);

  await publicClient.waitForTransactionReceipt({ hash: depositTx });

  const payoutTx = await contract.write.benchmarkPayoutOnly([
    recipient,
    payoutAmount,
  ]);
  console.log("benchmarkPayoutOnly tx hash =", payoutTx);

  const receipt = await publicClient.waitForTransactionReceipt({ hash: payoutTx });
  console.log("gasUsed =", receipt.gasUsed.toString());

  const eventAbi = parseAbiItem(
    "event PayoutExecuted(address indexed recipient, uint256 amount)"
  );

  let recipientValue: string | null = null;
  let amountValue: string | null = null;

  for (const log of receipt.logs) {
    try {
      const decoded = decodeEventLog({
        abi: [eventAbi],
        data: log.data,
        topics: log.topics,
      });
      if (decoded.eventName === "PayoutExecuted") {
        recipientValue = String(decoded.args.recipient);
        amountValue = decoded.args.amount?.toString() || null;
        console.log("PayoutExecuted recipient =", recipientValue);
        console.log("PayoutExecuted amount =", amountValue);
      }
    } catch {
      // ignore unrelated logs
    }
  }

  ensureDir(resultDir);

  const result = {
    metric: "Gas_payout_only",
    network: "kurtosis",
    caseTag,
    nSeller,
    nBuyer,
    settlementAddress,
    verifierAddress,
    txHash: payoutTx,
    gasUsed: receipt.gasUsed.toString(),
    payoutMode: "benchmarkPayoutOnly_single",
    payoutAmountWei: payoutAmount.toString(),
    recipient: recipientValue,
    emittedAmount: amountValue,
  };

  const outputPath = path.join(resultDir, `gas_payout_only_${caseTag}.json`);
  fs.writeFileSync(outputPath, JSON.stringify(result, null, 2));
  console.log("Saved result to:", outputPath);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
