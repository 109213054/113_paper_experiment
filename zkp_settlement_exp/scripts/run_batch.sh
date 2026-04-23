#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-balanced}"
REPEAT="${2:-3}"

PTAU_DIR="ptau"
PTAU_POWER="${PTAU_POWER:-17}"
PTAU_PREFIX="pot${PTAU_POWER}"
PTAU_FINAL="${PTAU_DIR}/${PTAU_PREFIX}_final.ptau"

RESULT_DIR="results/raw"
CSV_FILE="${RESULT_DIR}/batch_metrics_9cases.csv"

mkdir -p "${PTAU_DIR}"
mkdir -p "${RESULT_DIR}"
mkdir -p "build"

echo "=== Batch experiment start ==="
echo "Mode        : ${MODE}"
echo "Repeat      : ${REPEAT}"
echo "PTAU power  : ${PTAU_POWER}"

# -------------------------
# 0. Check npm dependencies
# -------------------------
if [ ! -d "node_modules" ]; then
  echo "[0] Installing npm dependencies..."
  npm install
fi

# -------------------------
# 1. Check ptau
# -------------------------
if [ ! -f "${PTAU_FINAL}" ]; then
  echo "[1] Generating ${PTAU_PREFIX}..."
  snarkjs powersoftau new bn128 "${PTAU_POWER}" "${PTAU_DIR}/${PTAU_PREFIX}_0000.ptau" -v
  echo "batch-ptau-randomness" | snarkjs powersoftau contribute \
    "${PTAU_DIR}/${PTAU_PREFIX}_0000.ptau" \
    "${PTAU_DIR}/${PTAU_PREFIX}_0001.ptau" \
    --name="batch contribution" -v
  snarkjs powersoftau prepare phase2 \
    "${PTAU_DIR}/${PTAU_PREFIX}_0001.ptau" \
    "${PTAU_FINAL}"
else
  echo "[1] Using existing ${PTAU_FINAL}"
fi

# -------------------------
# 2. Prepare CSV header
# -------------------------
if [ ! -f "${CSV_FILE}" ]; then
  echo "nSeller,nBuyer,mode,constraints,proof_size_bytes,pk_size_bytes,vk_size_bytes,prove_time_ms_avg,verify_time_ms_avg" > "${CSV_FILE}"
fi

run_case() {
  local nSeller="$1"
  local nBuyer="$2"
  local mode="$3"
  local repeat="$4"

  local case_name="${nSeller}_${nBuyer}_${mode}"
  local main_file="circuits/main/generated/settlement_${nSeller}_${nBuyer}.circom"
  local build_dir="build/experiment_${case_name}"
  local input_dir="inputs/generated/experiment/${case_name}"
  local input_json="${input_dir}/input.json"

  local r1cs_file="${build_dir}/settlement_${nSeller}_${nBuyer}.r1cs"
  local sym_file="${build_dir}/settlement_${nSeller}_${nBuyer}.sym"
  local wasm_dir="${build_dir}/settlement_${nSeller}_${nBuyer}_js"
  local wasm_file="${wasm_dir}/settlement_${nSeller}_${nBuyer}.wasm"

  local zkey_init="${build_dir}/circuit_0000.zkey"
  local zkey_final="${build_dir}/circuit_final.zkey"
  local vk_file="${build_dir}/verification_key.json"
  local witness_file="${build_dir}/witness.wtns"
  local proof_file="${build_dir}/proof.json"
  local public_file="${build_dir}/public.json"

  echo "--------------------------------------------------"
  echo "[CASE] ${case_name}"
  echo "[INFO] nSeller=${nSeller}, nBuyer=${nBuyer}, mode=${mode}"

  mkdir -p "${build_dir}"

  # -------------------------
  # Generate main circuit
  # -------------------------
  echo "[STEP] generate main"
  node scripts/gen_main.js "${nSeller}" "${nBuyer}"

  # -------------------------
  # Compile (cached)
  # -------------------------
  if [ ! -f "${r1cs_file}" ] || [ ! -f "${wasm_file}" ] || [ ! -f "${sym_file}" ]; then
    echo "[STEP] compile circom"
    circom "${main_file}" --r1cs --wasm --sym -o "${build_dir}"
  else
    echo "[STEP] compile circom (skip, cached)"
  fi

  # -------------------------
  # Generate input
  # -------------------------
  echo "[STEP] generate input"
  node scripts/gen_input_experiment.js "${nSeller}" "${nBuyer}" "${mode}"

  if [ ! -f "${input_json}" ]; then
    echo "ERROR: input not found: ${input_json}"
    exit 1
  fi

  # -------------------------
  # Constraint count
  # -------------------------
  local constraints
  constraints=$(snarkjs r1cs info "${r1cs_file}" 2>/dev/null | awk -F': ' '/# of Constraints/ {print $2}')
  if [ -z "${constraints:-}" ]; then
    constraints=$(snarkjs r1cs info "${r1cs_file}" 2>/dev/null | grep -i "constraint" | head -n 1 | grep -oE '[0-9]+' | tail -n 1 || true)
  fi
  constraints="${constraints:-0}"

  # -------------------------
  # Setup (cached)
  # -------------------------
  if [ ! -f "${zkey_final}" ] || [ ! -f "${vk_file}" ]; then
    echo "========================================"
    echo "[SETUP] START groth16 setup"
    echo "[SETUP] r1cs: ${r1cs_file}"
    echo "[SETUP] ptau: ${PTAU_FINAL}"
    echo "[SETUP] output: ${zkey_init}"
    echo "========================================"

    (
      while true; do
        echo "[SETUP] still running... $(date '+%F %T')"
        sleep 90
      done
    ) &
    heartbeat_pid=$!

    snarkjs groth16 setup \
      "${r1cs_file}" \
      "${PTAU_FINAL}" \
      "${zkey_init}"

    kill "${heartbeat_pid}" 2>/dev/null || true
    wait "${heartbeat_pid}" 2>/dev/null || true

    echo "========================================"
    echo "[SETUP] DONE groth16 setup"
    echo "========================================"

    echo "[STEP] zkey contribute"
    echo "batch-zkey-randomness-${case_name}" | snarkjs zkey contribute \
      "${zkey_init}" \
      "${zkey_final}" \
      --name="batch zkey contribution ${case_name}" -v >/dev/null

    echo "[STEP] export verification key"
    snarkjs zkey export verificationkey \
      "${zkey_final}" \
      "${vk_file}"
  else
    echo "[SETUP] skip, existing zkey/vk found"
  fi

  # -------------------------
  # Witness
  # -------------------------
  echo "[STEP] witness"
  node "${wasm_dir}/generate_witness.js" \
    "${wasm_file}" \
    "${input_json}" \
    "${witness_file}"

  # -------------------------
  # Repeated prove / verify
  # -------------------------
  local total_prove_ns=0
  local total_verify_ns=0

  for ((i=1; i<=repeat; i++)); do
    local prove_start prove_end prove_ns
    local verify_start verify_end verify_ns

    echo "[STEP] prove/verify round ${i}/${repeat}"

    prove_start=$(date +%s%N)
    snarkjs groth16 prove \
      "${zkey_final}" \
      "${witness_file}" \
      "${proof_file}" \
      "${public_file}" >/dev/null
    prove_end=$(date +%s%N)
    prove_ns=$((prove_end - prove_start))
    total_prove_ns=$((total_prove_ns + prove_ns))

    verify_start=$(date +%s%N)
    snarkjs groth16 verify \
      "${vk_file}" \
      "${public_file}" \
      "${proof_file}" >/dev/null
    verify_end=$(date +%s%N)
    verify_ns=$((verify_end - verify_start))
    total_verify_ns=$((total_verify_ns + verify_ns))
  done

  # -------------------------
  # File sizes
  # -------------------------
  local proof_size_bytes
  local pk_size_bytes
  local vk_size_bytes
  local prove_time_ms_avg
  local verify_time_ms_avg

  proof_size_bytes=$(stat -c%s "${proof_file}")
  pk_size_bytes=$(stat -c%s "${zkey_final}")
  vk_size_bytes=$(stat -c%s "${vk_file}")

  prove_time_ms_avg=$(awk "BEGIN {printf \"%.3f\", (${total_prove_ns} / ${repeat}) / 1000000}")
  verify_time_ms_avg=$(awk "BEGIN {printf \"%.3f\", (${total_verify_ns} / ${repeat}) / 1000000}")

  # -------------------------
  # Append CSV
  # -------------------------
  echo "${nSeller},${nBuyer},${mode},${constraints},${proof_size_bytes},${pk_size_bytes},${vk_size_bytes},${prove_time_ms_avg},${verify_time_ms_avg}" >> "${CSV_FILE}"

  echo "[DONE] ${case_name}"
  echo "  constraints        = ${constraints}"
  echo "  proof_size_bytes   = ${proof_size_bytes}"
  echo "  pk_size_bytes      = ${pk_size_bytes}"
  echo "  vk_size_bytes      = ${vk_size_bytes}"
  echo "  prove_time_ms_avg  = ${prove_time_ms_avg}"
  echo "  verify_time_ms_avg = ${verify_time_ms_avg}"
}

# -------------------------
# 3. Formal experiment:
#    9 unique cases
#    (10,10) (10,20) (10,30)
#    (20,10) (20,20) (20,30)
#    (30,10) (30,20) (30,30)
# -------------------------
for nSeller in 10 20 30; do
  for nBuyer in 10 20 30; do
    run_case "${nSeller}" "${nBuyer}" "${MODE}" "${REPEAT}"
  done
done

echo "=== Batch experiment finished ==="
echo "CSV written to: ${CSV_FILE}"
