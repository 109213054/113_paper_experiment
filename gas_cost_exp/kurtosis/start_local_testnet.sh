#!/usr/bin/env bash
set -euo pipefail

ENCLAVE_NAME="${1:-gas-cost-exp}"
PACKAGE_NAME="github.com/ethpandaops/ethereum-package@6.1.0"
ARGS_FILE="kurtosis/network_params.yaml"

echo "[INFO] Removing old Kurtosis enclave if exists: ${ENCLAVE_NAME}"
kurtosis enclave rm -f "${ENCLAVE_NAME}" || true

echo "[INFO] Starting Kurtosis enclave: ${ENCLAVE_NAME}"
echo "[INFO] Package: ${PACKAGE_NAME}"
echo "[INFO] Args file: ${ARGS_FILE}"

kurtosis run "${PACKAGE_NAME}" \
  --enclave "${ENCLAVE_NAME}" \
  --args-file "${ARGS_FILE}"

echo
echo "[INFO] Kurtosis enclave started."
echo "[INFO] To inspect services:"
echo "       kurtosis enclave inspect ${ENCLAVE_NAME}"
echo
echo "[INFO] To list all enclaves:"
echo "       kurtosis enclave ls"
