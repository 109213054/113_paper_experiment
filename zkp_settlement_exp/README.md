# ZKP Settlement Resource Consumption Experiment

## 1. Project Goal
This project evaluates the resource consumption of the settlement zero-knowledge proof (ZKP) circuit under different numbers of sellers and buyers.

The experiment focuses on the following four objectives:

1. Effect of increasing sellers/buyers on proof size
2. Effect of increasing sellers/buyers on proving key size
3. Effect of increasing sellers/buyers on verification key size
4. Effect of increasing sellers/buyers on proof generation and verification time

## 2. Experiment Scope
This project implements the first version of the settlement circuit only.

Current assumptions:
- Only one DSO balance direction is considered
- Assume total buyer energy >= total seller energy
- The circuit focuses on resource measurement only
- No blockchain deployment is included in this phase

## 3. Project Structure
- `circuits/` : Circom circuit files
- `circuits/main/` : Main circuit entry files for specific test cases
- `scripts/` : Scripts for input generation and experiment execution
- `inputs/generated/` : Auto-generated test inputs
- `build/` : Build outputs, witness, zkey, proof, logs
- `results/raw/` : Raw experimental data
- `results/figures/` : Generated figures
- `docs/notes/` : Experiment notes and planning records

## 4. Main Experimental Metrics
For each `(nSeller, nBuyer)` case, record:
- number of constraints
- proof size
- proving key size
- verification key size
- witness generation time
- proof generation time
- verification time

## 5. Current Development Status
- [x] Project skeleton initialized
- [ ] Linux environment setup
- [ ] Circom circuit implementation
- [ ] Input generator
- [ ] Single-case execution script
- [ ] Batch experiment script
- [ ] Result collection
- [ ] Figure plotting

## 6. Planned Experiment Cases
Initial symmetric test cases:
- (1,1)
- (2,2)
- (4,4)
- (8,8)
- (16,16)
- (32,32)

## 7. Notes
This repository is intended for reproducible ZKP resource evaluation experiments.

