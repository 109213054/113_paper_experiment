import { config as dotenvConfig } from "dotenv";
import { defineConfig } from "hardhat/config";
import hardhatViem from "@nomicfoundation/hardhat-viem";

dotenvConfig();

const RPC_URL = process.env.RPC_URL || "http://127.0.0.1:32841";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const CHAIN_ID = Number(process.env.CHAIN_ID || "3151908");

export default defineConfig({
  plugins: [hardhatViem],
  solidity: "0.8.20",
  networks: {
    hardhat: {
      type: "edr-simulated",
      chainType: "l1",
    },
    kurtosis: {
      type: "http",
      chainType: "l1",
      url: RPC_URL,
      chainId: CHAIN_ID,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
    },
  },
});
