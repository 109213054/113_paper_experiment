# ZKP Settlement Resource Consumption Experiment

## 1. Project Goal
This project develops and evaluates a settlement zero-knowledge proof (ZKP) circuit for privacy-preserving electricity settlement.

The long-term experiment goals are:

1. Effect of increasing sellers/buyers on proof size
2. Effect of increasing sellers/buyers on proving key size
3. Effect of increasing sellers/buyers on verification key size
4. Effect of increasing sellers/buyers on proof generation and verification time

## 2. Current Scope
The current repository provides a **Phase 3 minimal runnable implementation** of the settlement ZKP circuit.

At this stage, the project already supports:

- price commitment (`H_price_epoch`)
- claim commitments (`mClaimSell`, `mClaimBuy`)
- actual commitments (`mActualSell`, `mActualBuy`)
- seller payout verification (`payToSeller`)
- signed DSO balance:
  - `balDSOAbs`
  - `balDSOSign`
- classification bits:
  - `sellCase`
  - `buyCase`

### Current fixed assumptions
- current handoff version is fixed to `Settlement(1,1)`
- current execution target is **single-case runnable verification**
- Docker-based reproducible execution is supported
- variable seller/buyer counts are **not yet implemented**
- batch experiments and plotting are **not yet implemented**

## 3. Current Minimal Runnable Modes
The current Phase 3 minimal runnable version supports:

- `receive`
- `pay`
- `zero`
- `classify1`
- `classify2`

### Meaning of classification bits
- `sellCase = 0` → `sellActual <= claimSell`
- `sellCase = 1` → `sellActual > claimSell`
- `buyCase = 0` → `buyActual <= claimBuy`
- `buyCase = 1` → `buyActual > claimBuy`

### Meaning of signed DSO balance
- `balDSOSign = 0` → DSO receives
- `balDSOSign = 1` → DSO pays
- `balDSOAbs = |sellerSum - buyerSum|`

## 4. Project Structure
- `circuits/` : Circom circuit files
- `circuits/main/` : Main circuit entry files
- `scripts/` : Scripts for input generation and experiment execution
- `inputs/generated/` : Auto-generated test inputs
- `build/` : Build outputs, witness, zkey, proof, logs
- `results/raw/` : Raw experimental data
- `results/figures/` : Generated figures
- `docs/notes/` : Experiment notes and planning records
- `ptau/` : Powers of Tau files (ignored by Git)
- `scripts/gen_input_debug.js` : fixed `(1,1)` debug / handoff input generator
- `scripts/gen_input_experiment.js` : scalable experiment input generator for future variable `(nSeller, nBuyer)` experiments
- `scripts/run_one.sh` : one-command minimal runnable flow for Phase 3 handoff

## 5. Current Development Status
- [x] Linux / Docker environment setup
- [x] Circom circuit implementation
- [x] JS input generator
- [x] Signed DSO balance support
- [x] Claim / actual commitment support
- [x] Phase 3 classification bit support
- [ ] Single-case execution script cleanup
- [ ] Variable `(nSeller, nBuyer)` support
- [ ] Batch experiment script
- [ ] Result collection
- [ ] Figure plotting

## 6. Environment Setup

This project is recommended to run in Docker for reproducibility.

### Host Requirements
- Linux host
- Docker installed
- Git installed

### Container Tools
- Ubuntu 22.04
- Node.js 20.x
- npm
- snarkjs
- Rust
- cargo
- circom
- Python 3

## 7. Build Docker Image

```bash
docker build -t zkp-settlement-exp:1.0 .

## 8. Run minimal Runnable Flow

### Example : receive
docker run --rm -it -v $(pwd):/workspace zkp-settlement-exp:1.0 bash scripts/run_one.sh receive

### Other modes
docker run --rm -it -v $(pwd):/workspace zkp-settlement-exp:1.0 bash scripts/run_one.sh pay
docker run --rm -it -v $(pwd):/workspace zkp-settlement-exp:1.0 bash scripts/run_one.sh zero
docker run --rm -it -v $(pwd):/workspace zkp-settlement-exp:1.0 bash scripts/run_one.sh classify1
docker run --rm -it -v $(pwd):/workspace zkp-settlement-exp:1.0 bash scripts/run_one.sh classify2

### 9. Current Handoff Goal
The current handoff target is:
- anyone can clone the repository
- build the Docker image
- run one command
- reproduce the full Phase 3 proof flow:
	- compile
	- setup
	- input generation
	- witness generation
	- proof generation
	- proof verification

### Not Yet Completed
The following parts are not yet implemented in this handoff version:
- variable seller / buyer counts
- batch execution for multiple (nSeller, nBuyer) cases
- automatic metric collection
- plotting / final result figures


### How To Run
The current minimal runnable handoff flow uses:
- `scripts/gen_input_debug.js`
- `scripts/run_one.sh`

The future scalable experiment flow will use:
- `scripts/gen_input_experiment.js`
- `scripts/run_batch.sh`

