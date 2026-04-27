#!/usr/bin/env bash
set -euo pipefail

ENCLAVE_NAME="${1:-gas-cost-exp}"

echo "[INFO] Stopping Kurtosis enclave: ${ENCLAVE_NAME}"
kurtosis enclave rm "${ENCLAVE_NAME}" -f
echo "[INFO] Enclave removed."
