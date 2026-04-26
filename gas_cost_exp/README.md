# Gas Cost Experiment

## 1. Project Goal

This experiment evaluates the on-chain gas cost of the proposed P2P energy trading settlement mechanism.

The experiment focuses on measuring the gas consumption of:

- ZKP proof verification
- failed verification
- settlement execution after successful verification
- payout-related gas overhead
- contract deployment gas

## 2. Relationship to the First Experiment

This experiment reuses the completed ZKP circuit and proof-generation flow from the first experiment (`zkp_settlement_exp`).

The first experiment focused on:
- circuit resource consumption
- proof size
- proving key size
- verification key size
- proof generation / verification time

The current experiment focuses on:
- smart contract deployment
- on-chain proof verification gas
- on-chain settlement gas

## 3. Directory Overview

- `zkp/` : ZKP circuits, scripts, ptau, build outputs, proof artifacts
- `hardhat/` : Solidity contracts, deployment scripts, gas measurement scripts
- `kurtosis/` : local Ethereum testnet setup and control scripts
- `data/` : input data, seller lists, payout amounts
- `results/` : raw results, processed summaries, figures
- `docs/notes/` : experiment planning and notes

## 4. Current Status

- [x] project skeleton initialized
- [ ] Kurtosis local testnet configured
- [ ] Hardhat project initialized
- [ ] Verifier.sol generated for each n
- [ ] Settlement.sol implemented
- [ ] deployment script implemented
- [ ] gas test scripts implemented
- [ ] raw gas results collected
- [ ] figures plotted

## 5. Notes

This experiment is designed for reproducible gas-cost evaluation of on-chain ZKP verification and settlement execution.

