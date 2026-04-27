import { config as dotenvConfig } from "dotenv";
import { defineConfig } from "hardhat/config";
import hardhatToolboxViem from "@nomicfoundation/hardhat-toolbox-viem";

dotenvConfig();

const RPC_URL = process.env.RPC_URL || "http://127.0.0.1:8545";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const CHAIN_ID = Number(process.env.CHAIN_ID || "31337");

const kurtosisAccounts =
  PRIVATE_KEY && PRIVATE_KEY.startsWith("0x") ? [PRIVATE_KEY as `0x${string}`] : [];

export default defineConfig({
  plugins: [hardhatToolboxViem],
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
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
      accounts: kurtosisAccounts,
    },
  },
});
