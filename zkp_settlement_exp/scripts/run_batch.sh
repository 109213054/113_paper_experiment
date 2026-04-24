#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Batch experiment runner for scalable ZKP resource analysis
#
# Current assumptions:
# - uses gen_main.js to generate main circuit
# - uses gen_input_experiment.js to generate input
# - build directory format:
#     build/experiment_<nSeller>_<nBuyer>/
# - input directory format:
#     inputs/generated/experiment/<nSeller>_<nBuyer>_<mode>/input.json
#
# Usage examples:
#   bash scripts/run_batch.sh
#   PTAU_POWER=18 TIME_REPEAT=10 MODE=balanced bash scripts/run_batch.sh
# =========================================================

# -------------------------
# Configurable parameters
# -------------------------
MODE="${MODE:-balanced}"
TIME_REPEAT="${TIME_REPEAT:-50}"
PTAU_POWER="${PTAU_POWER:-18}"

PTAU_DIR="ptau"
PTAU_PREFIX="pot${PTAU_POWER}"
PTAU_0000="${PTAU_DIR}/${PTAU_PREFIX}_0000.ptau"
PTAU_0001="${PTAU_DIR}/${PTAU_PREFIX}_0001.ptau"
PTAU_FINAL="${PTAU_DIR}/${PTAU_PREFIX}_final.ptau"

RESULT_DIR="results/raw"
RESULT_CSV="${RESULT_DIR}/batch_metrics_50.csv"

# Stage 1: fixed buyer, vary seller
FIXED_BUYERS=(10 20 30)
VARIED_SELLERS=(5 10 15 20 25 30)

# Stage 2: fixed seller, vary buyer
FIXED_SELLERS=(10 20 30)
VARIED_BUYERS=(5 10 15 20 25 30)

# -------------------------
# Helpers
# -------------------------
ensure_npm() {
  if [ ! -d "node_modules" ]; then
    echo "[INIT] node_modules not found. Installing npm dependencies..."
    npm install
  fi
}

ensure_dirs() {
  mkdir -p "${PTAU_DIR}"
  mkdir -p "${RESULT_DIR}"
  mkdir -p build
  mkdir -p inputs/generated/experiment
  mkdir -p circuits/main/generated
}

ensure_ptau() {
  if [ -f "${PTAU_FINAL}" ]; then
    echo "[PTAU] Using existing ${PTAU_FINAL}"
    return
  fi

  echo "[PTAU] ${PTAU_FINAL} not found. Generating ${PTAU_PREFIX}..."

  if [ ! -f "${PTAU_0000}" ]; then
    snarkjs powersoftau new bn128 "${PTAU_POWER}" "${PTAU_0000}" -v
  else
    echo "[PTAU] Using existing ${PTAU_0000}"
  fi

  if [ ! -f "${PTAU_0001}" ]; then
    echo "batch-ptau-randomness-${PTAU_POWER}" | snarkjs powersoftau contribute \
      "${PTAU_0000}" \
      "${PTAU_0001}" \
      --name="batch contribution" -v
  else
    echo "[PTAU] Using existing ${PTAU_0001}"
  fi

  if [ ! -f "${PTAU_FINAL}" ]; then
    snarkjs powersoftau prepare phase2 "${PTAU_0001}" "${PTAU_FINAL}" -v
  fi

  echo "[PTAU] Generated ${PTAU_FINAL}"
}

ensure_csv_header() {
  if [ ! -f "${RESULT_CSV}" ]; then
    echo "phase,fixed_role,fixed_value,nSeller,nBuyer,mode,proof_size_bytes,pk_size_bytes,vk_size_bytes,prove_time_ms_avg,verify_time_ms_avg" > "${RESULT_CSV}"
  fi
}

get_file_size() {
  local f="$1"
  stat -c%s "${f}"
}

measure_prove_once() {
  local build_dir="$1"
  local mode="$2"
  local idx="$3"

  local witness_file="${build_dir}/witness_${mode}.wtns"
  local zkey_file="${build_dir}/circuit_final.zkey"
  local proof_file="${build_dir}/proof_${mode}_rep${idx}.json"
  local public_file="${build_dir}/public_${mode}_rep${idx}.json"

  local start_ns
  local end_ns
  start_ns=$(date +%s%N)

  snarkjs groth16 prove \
    "${zkey_file}" \
    "${witness_file}" \
    "${proof_file}" \
    "${public_file}" >/dev/null 2>&1

  end_ns=$(date +%s%N)
  awk "BEGIN {printf \"%.3f\", (${end_ns} - ${start_ns}) / 1000000}"
}

measure_verify_once() {
  local build_dir="$1"
  local mode="$2"
  local idx="$3"

  local vk_file="${build_dir}/verification_key.json"
  local proof_file="${build_dir}/proof_${mode}_rep${idx}.json"
  local public_file="${build_dir}/public_${mode}_rep${idx}.json"

  local start_ns
  local end_ns
  start_ns=$(date +%s%N)

  snarkjs groth16 verify \
    "${vk_file}" \
    "${public_file}" \
    "${proof_file}" >/dev/null 2>&1

  end_ns=$(date +%s%N)
  awk "BEGIN {printf \"%.3f\", (${end_ns} - ${start_ns}) / 1000000}"
}

measure_time_averages() {
  local build_dir="$1"
  local mode="$2"
  local repeat="$3"

  local prove_sum="0"
  local verify_sum="0"

  for ((i=1; i<=repeat; i++)); do
    local p_ms
    local v_ms

    p_ms=$(measure_prove_once "${build_dir}" "${mode}" "${i}")
    v_ms=$(measure_verify_once "${build_dir}" "${mode}" "${i}")

    prove_sum=$(awk "BEGIN {printf \"%.6f\", ${prove_sum} + ${p_ms}}")
    verify_sum=$(awk "BEGIN {printf \"%.6f\", ${verify_sum} + ${v_ms}}")

    # 進度訊息改送到 stderr，避免污染 command substitution 結果
    echo "    [TIME] repetition ${i}/${repeat}: prove=${p_ms} ms, verify=${v_ms} ms" >&2
  done

  local prove_avg
  local verify_avg
  prove_avg=$(awk "BEGIN {printf \"%.3f\", ${prove_sum} / ${repeat}}")
  verify_avg=$(awk "BEGIN {printf \"%.3f\", ${verify_sum} / ${repeat}}")

  # 只有平均值輸出到 stdout
  echo "${prove_avg},${verify_avg}"
}

run_case() {
  local phase="$1"
  local fixed_role="$2"
  local fixed_value="$3"
  local nSeller="$4"
  local nBuyer="$5"

  local case_tag="${nSeller}_${nBuyer}"
  local build_dir="build/experiment_${case_tag}"
  local main_file="circuits/main/generated/settlement_${case_tag}.circom"
  local input_json="inputs/generated/experiment/${case_tag}_${MODE}/input.json"

  echo "======================================================"
  echo "[CASE] phase=${phase}, fixed_role=${fixed_role}, fixed_value=${fixed_value}, nSeller=${nSeller}, nBuyer=${nBuyer}, mode=${MODE}"
  echo "======================================================"

  mkdir -p "${build_dir}"

  # 1. Generate main circuit
  echo "[1/7] Generate main circuit..."
  node scripts/gen_main.js "${nSeller}" "${nBuyer}"

  # 2. Compile
  echo "[2/7] Compile..."
  circom "${main_file}" --r1cs --wasm --sym -o "${build_dir}"

  local base_name="settlement_${case_tag}"
  local r1cs_file="${build_dir}/${base_name}.r1cs"
  local wasm_file="${build_dir}/${base_name}_js/${base_name}.wasm"

  # 3. Generate input
  echo "[3/7] Generate experiment input..."
  node scripts/gen_input_experiment.js "${nSeller}" "${nBuyer}" "${MODE}"

  if [ ! -f "${input_json}" ]; then
    echo "ERROR: input file not found: ${input_json}"
    exit 1
  fi

  # 4. Setup
  echo "[4/7] Setup..."
  snarkjs groth16 setup \
    "${r1cs_file}" \
    "${PTAU_FINAL}" \
    "${build_dir}/circuit_0000.zkey"

  echo "batch-zkey-randomness-${case_tag}" | snarkjs zkey contribute \
    "${build_dir}/circuit_0000.zkey" \
    "${build_dir}/circuit_final.zkey" \
    --name="batch zkey contribution ${case_tag}" -v >/dev/null 2>&1

  snarkjs zkey export verificationkey \
    "${build_dir}/circuit_final.zkey" \
    "${build_dir}/verification_key.json"

  # 5. Generate witness
  echo "[5/7] Generate witness..."
  node "${build_dir}/${base_name}_js/generate_witness.js" \
    "${wasm_file}" \
    "${input_json}" \
    "${build_dir}/witness_${MODE}.wtns"

  # 6. Collect static metrics
  echo "[6/7] Collect static metrics..."
  local proof_size_bytes
  local pk_size_bytes
  local vk_size_bytes

  pk_size_bytes=$(get_file_size "${build_dir}/circuit_final.zkey")
  vk_size_bytes=$(get_file_size "${build_dir}/verification_key.json")

  # 7. Measure repeated prove / verify times
  echo "[7/7] Measure prove / verify times (${TIME_REPEAT} repetitions)..."
  local averages
  averages=$(measure_time_averages "${build_dir}" "${MODE}" "${TIME_REPEAT}")

  local prove_time_ms_avg
  local verify_time_ms_avg
  prove_time_ms_avg=$(echo "${averages}" | cut -d',' -f1)
  verify_time_ms_avg=$(echo "${averages}" | cut -d',' -f2)

  # proof size after rep1 proof generation
  proof_size_bytes=$(get_file_size "${build_dir}/proof_${MODE}_rep1.json")

  echo "[CSV] Append metrics..."
  echo "${phase},${fixed_role},${fixed_value},${nSeller},${nBuyer},${MODE},${proof_size_bytes},${pk_size_bytes},${vk_size_bytes},${prove_time_ms_avg},${verify_time_ms_avg}" >> "${RESULT_CSV}"

  echo "[DONE] Recorded: ${case_tag}"
  echo "       proof_size_bytes = ${proof_size_bytes}"
  echo "       pk_size_bytes    = ${pk_size_bytes}"
  echo "       vk_size_bytes    = ${vk_size_bytes}"
  echo "       prove_avg_ms     = ${prove_time_ms_avg}"
  echo "       verify_avg_ms    = ${verify_time_ms_avg}"
}

# -------------------------
# Main
# -------------------------
echo "=== Batch ZKP Resource Experiment ==="
echo "MODE=${MODE}"
echo "TIME_REPEAT=${TIME_REPEAT}"
echo "PTAU_POWER=${PTAU_POWER}"
echo "PTAU_FINAL=${PTAU_FINAL}"
echo "RESULT_CSV=${RESULT_CSV}"

ensure_npm
ensure_dirs
ensure_ptau
ensure_csv_header

# Stage 1: fixed buyer, vary seller
for fixed_buyer in "${FIXED_BUYERS[@]}"; do
  for varied_seller in "${VARIED_SELLERS[@]}"; do
    run_case "stage1" "buyer" "${fixed_buyer}" "${varied_seller}" "${fixed_buyer}"
  done
done

# Stage 2: fixed seller, vary buyer
for fixed_seller in "${FIXED_SELLERS[@]}"; do
  for varied_buyer in "${VARIED_BUYERS[@]}"; do
    run_case "stage2" "seller" "${fixed_seller}" "${fixed_seller}" "${varied_buyer}"
  done
done

echo "======================================================"
echo "Batch experiment completed."
echo "CSV output: ${RESULT_CSV}"
echo "======================================================"


