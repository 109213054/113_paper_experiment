# Experiment Plan

## Objective
Measure how the number of sellers and buyers affects the resource consumption of the settlement ZKP circuit.

## Metrics
- Proof size
- Proving key size
- Verification key size
- Proof generation time
- Verification time

## First-Version Simplification
To avoid extra constraint overhead from signed comparison and selector logic, the first version only considers the case where:

total buyer energy >= total seller energy

Thus, the DSO balance direction is fixed in this version.

## Planned Workflow
1. Set up Linux environment
2. Install Circom and snarkjs
3. Implement first-version settlement circuit
4. Generate test inputs automatically
5. Run single-case experiment
6. Run batch experiments
7. Collect results into CSV
8. Plot figures

## Initial Cases
(1,1), (2,2), (4,4), (8,8), (16,16), (32,32)

