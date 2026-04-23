# Experiment Plan

## 1. Objective

This experiment aims to evaluate how the number of sellers and buyers affects the resource consumption of the settlement zero-knowledge proof (ZKP) circuit.

As the number of participants increases, the circuit must process more settlement-related data. This increases the number of private inputs, public inputs, and circuit constraints, which in turn affects the storage cost and computational cost of the proof system.

---

## 2. Evaluation Metrics

The experiment evaluates the following five main metrics:

1. Proof size
2. Proving key size
3. Verification key size
4. Proof generation time
5. Proof verification time

In addition, the number of constraints is also recorded as an auxiliary metric for later explanation and analysis.

---

## 3. Measurement Policy

### 3.1 Single-run metrics
The following metrics are structural outputs of a given circuit instance and only need to be measured once for each `(nSeller, nBuyer)` configuration:

- number of constraints
- proof size
- proving key size
- verification key size

### 3.2 Repeated-run metrics
The following metrics are time-related and should be measured repeatedly for each `(nSeller, nBuyer)` configuration, then averaged:

- proof generation time
- proof verification time

The current plan is to repeat the time-related measurements **100 times** per configuration and use the average value as the final result.

---

## 4. Core Experimental Setup

- The circuit structure is fixed, and only `nSeller` and `nBuyer` are changed.
- The current experiment mode is planned to use a fixed baseline setting for consistency.
- The x-axis represents the number of participants on the varying side.
- The y-axis represents one of the measured resource-consumption metrics.
- The current scalable experiment generator will be used for batch execution.

---

## 5. Stage 1: Fix Buyer Count, Vary Seller Count

In Stage 1, the buyer count is fixed and the seller count is varied.

### Fixed buyer counts
- 10
- 20
- 30

### Varying seller counts
- 10
- 20
- 30
- 40

### Stage 1 experiment matrix
- buyer = 10: `(10,10)`, `(20,10)`, `(30,10)`, `(40,10)`
- buyer = 20: `(10,20)`, `(20,20)`, `(30,20)`, `(40,20)`
- buyer = 30: `(10,30)`, `(20,30)`, `(30,30)`, `(40,30)`

### Stage 1 plotting plan
For each of the following metrics, one figure will be generated:

1. Proof size
2. Proving key size
3. Verification key size
4. Proof generation time
5. Proof verification time

Each figure will contain **three lines**, corresponding to the three fixed buyer counts (10, 20, 30).

---

## 6. Stage 2: Fix Seller Count, Vary Buyer Count

In Stage 2, the seller count is fixed and the buyer count is varied.

### Fixed seller counts
- 10
- 20
- 30

### Varying buyer counts
- 10
- 20
- 30
- 40

### Stage 2 experiment matrix
- seller = 10: `(10,10)`, `(10,20)`, `(10,30)`, `(10,40)`
- seller = 20: `(20,10)`, `(20,20)`, `(20,30)`, `(20,40)`
- seller = 30: `(30,10)`, `(30,20)`, `(30,30)`, `(30,40)`

### Stage 2 plotting plan
For each of the following metrics, one figure will be generated:

1. Proof size
2. Proving key size
3. Verification key size
4. Proof generation time
5. Proof verification time

Each figure will contain **three lines**, corresponding to the three fixed seller counts (10, 20, 30).

---

## 7. Total Number of Figures

The full experiment is divided into two stages:

- Stage 1: 5 figures
- Stage 2: 5 figures

Therefore, the final result presentation will contain **10 figures** in total.

---

## 8. Constraint Count Usage

The number of constraints is recorded for each `(nSeller, nBuyer)` configuration.

At the current planning stage, constraint count is **not intended to be plotted directly**. Instead, it will be used later as a supporting metric to explain:

- why proof size changes
- why proving key / verification key sizes change
- why proof generation time and verification time increase with circuit size

---

## 9. Current Execution Plan

The implementation will proceed in the following order:

1. Finalize experiment planning document
2. Implement scalable main-circuit generation
3. Implement batch execution script
4. Collect metrics into CSV
5. Run all experiment configurations
6. Plot figures
7. Write result analysis

---

## 10. Current Notes

- The current minimal runnable handoff version has already been completed.
- The next step is not to plot figures immediately, but to first build the scalable batch-execution pipeline.
- The experiment generator and batch runner must support variable `(nSeller, nBuyer)` values.
- A CSV-based result collection workflow will be used before plotting.

---

## 11. Planned Output Files

The expected output artifacts include:

- generated main circuits for each `(nSeller, nBuyer)` case
- build artifacts for each case
- input files for each case
- raw metrics CSV
- final plotted figures

---

## 12. Summary

This experiment studies the effect of participant scaling on the resource consumption of the settlement ZKP circuit.

The evaluation focuses on:

- proof size
- proving key size
- verification key size
- proof generation time
- proof verification time

The experiment is divided into two stages:

- fix buyer count, vary seller count
- fix seller count, vary buyer count

Each stage contains five figures, and the final result will contain ten figures in total.
