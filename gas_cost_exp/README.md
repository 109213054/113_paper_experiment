# Gas Cost Experiment

## 1. Project Goal

This experiment evaluates the on-chain gas cost of the proposed P2P energy trading settlement mechanism.

The current implementation focuses on:

- on-chain ZKP verification gas
- failed verification gas
- settlement transaction gas
- contract deployment workflow over a local Kurtosis Ethereum-compatible testnet

## 2. Relationship to the First Experiment

This experiment reuses the completed ZKP circuit and proof-generation flow from the first experiment (`zkp_settlement_exp`).

The first experiment focused on:
- circuit resource consumption
- proof size
- proving key size
- verification key size
- proof generation / verification time

This second experiment focuses on:
- verifier deployment
- settlement contract deployment
- on-chain proof verification gas
- on-chain failed verification gas
- on-chain settlement gas

## 3. Current Directory Overview

- `zkp/` : ZKP circuits, scripts, ptau, build outputs, proof artifacts
- `hardhat/` : Solidity contracts, deployment scripts, gas measurement scripts
- `kurtosis/` : local Ethereum testnet setup and control scripts
- `data/` : auxiliary input data
- `results/raw/` : raw JSON result files
- `results/processed/` : processed CSV summaries
- `results/figures/` : reserved for future plots
- `docs/notes/` : experiment planning and notes

## 4. Current Completed Metrics

For `n = 10`, the following metrics have been completed:

- `Gas_verify_success`
- `Gas_verify_fail`
- `Gas_settlement_success`

The current processed result file is:

- `results/processed/gas_summary.csv`

## 5. Important Interpretation Notes

### 5.1 Verify success / fail decision rule

For this phase, verification correctness is judged by:

- direct call to verifier contract
- settlement-level simulation result

The `BillVerified` event field is currently retained only as an observation field and is not used as the sole correctness criterion.

### 5.2 Current result status

Current CSV contains:
- gas usage
- settlement / verifier addresses
- tx hash
- proof/public input file paths
- expected direct verification result
- expected settlement simulation result
- event observation result

## 6. Current Status

- [x] project skeleton initialized
- [x] Kurtosis local testnet configured
- [x] Hardhat project initialized
- [x] Verifier contract generated for n=10
- [x] Settlement contract implemented (minimal version)
- [x] verifier + settlement deployment completed
- [x] gas test scripts implemented
- [x] raw JSON gas results collected
- [x] processed CSV summary generated
- [ ] deployment gas formally collected
- [ ] payout-only gas implemented
- [ ] larger n values implemented
- [ ] figures plotted

## 7. Reproducibility Workflow

### 7.1 ZKP side
1. Generate main circuit
2. Generate experiment input
3. Compile circuit
4. Run trusted setup
5. Generate witness
6. Generate proof / public signals
7. Export verification key
8. Export Solidity verifier

### 7.2 Chain side
1. Start Kurtosis local testnet
2. Configure `.env`
3. Deploy verifier and settlement
4. Run gas measurement scripts
5. Save raw JSON results
6. Collect processed CSV summary

## 8. Current Result Files

Examples:
- `results/raw/kurtosis/gas_verify_success_n10.json`
- `results/raw/kurtosis/gas_verify_fail_n10.json`
- `results/raw/kurtosis/gas_settlement_success_n10.json`
- `results/processed/gas_summary.csv`

## 9. Notes

This repository is currently at the first runnable milestone of the gas-cost experiment.
The next stage is to extend the same workflow to larger `n` and additional gas metrics.
