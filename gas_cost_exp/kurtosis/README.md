# Kurtosis Local Testnet

This directory contains helper files for starting and stopping a local Ethereum-compatible testnet for the gas cost experiment.

## Goal

The local testnet is used as the execution environment for:

- contract deployment
- proof verification calls
- settlement gas measurement

## Workflow

1. Start the local testnet with `start_local_testnet.sh`
2. Read the RPC endpoint
3. Put the RPC URL into `hardhat/.env`
4. Use Hardhat scripts to deploy contracts and run gas experiments
5. Stop the testnet with `stop_local_testnet.sh`
