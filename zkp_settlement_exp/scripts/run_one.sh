#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-receive}"
BUILD_DIR="build/phase3_signed_1_1"
PTAU_DIR="ptau"
PTAU_FINAL="${PTAU_DIR}/pot14_final.ptau"

echo "=== Phase 3 minimal runnable flow ==="
echo "Mode: ${MODE}"

# Install npm dependencies if missing
if [ ! -d "node_modules" ]; then
  echo "[0/7] node_modules not found. Installing npm dependencies..."
  npm install
fi

mkdir -p "${BUILD_DIR}"
mkdir -p "${PTAU_DIR}"

echo "[1/7] Compile circuit..."
circom circuits/main/settlement_main.circom --r1cs --wasm --sym -o "${BUILD_DIR}"

echo "[2/7] Check ptau..."
if [ ! -f "${PTAU_FINAL}" ]; then
  echo "ptau not found. Generating pot14..."
  snarkjs powersoftau new bn128 14 "${PTAU_DIR}/pot14_0000.ptau" -v
  echo "phase3-ptau-randomness" | snarkjs powersoftau contribute \
    "${PTAU_DIR}/pot14_0000.ptau" \
    "${PTAU_DIR}/pot14_0001.ptau" \
    --name="phase3 contribution" -v
  snarkjs powersoftau prepare phase2 \
    "${PTAU_DIR}/pot14_0001.ptau" \
    "${PTAU_FINAL}"
else
  echo "Using existing ${PTAU_FINAL}"
fi

echo "[3/7] Setup..."
snarkjs groth16 setup \
  "${BUILD_DIR}/settlement_main.r1cs" \
  "${PTAU_FINAL}" \
  "${BUILD_DIR}/circuit_0000.zkey"

echo "phase3-zkey-randomness" | snarkjs zkey contribute \
  "${BUILD_DIR}/circuit_0000.zkey" \
  "${BUILD_DIR}/circuit_final.zkey" \
  --name="phase3 zkey contribution" -v

snarkjs zkey export verificationkey \
  "${BUILD_DIR}/circuit_final.zkey" \
  "${BUILD_DIR}/verification_key.json"

echo "[4/7] Generate input..."
node scripts/gen_input.js "${MODE}"

INPUT_JSON="inputs/generated/phase3_signed_1_1_${MODE}/input.json"

echo "[5/7] Generate witness..."
node "${BUILD_DIR}/settlement_main_js/generate_witness.js" \
  "${BUILD_DIR}/settlement_main_js/settlement_main.wasm" \
  "${INPUT_JSON}" \
  "${BUILD_DIR}/witness_${MODE}.wtns"

echo "[6/7] Generate proof..."
snarkjs groth16 prove \
  "${BUILD_DIR}/circuit_final.zkey" \
  "${BUILD_DIR}/witness_${MODE}.wtns" \
  "${BUILD_DIR}/proof_${MODE}.json" \
  "${BUILD_DIR}/public_${MODE}.json"

echo "[7/7] Verify proof..."
snarkjs groth16 verify \
  "${BUILD_DIR}/verification_key.json" \
  "${BUILD_DIR}/public_${MODE}.json" \
  "${BUILD_DIR}/proof_${MODE}.json"

echo "=== Done: ${MODE} ==="

