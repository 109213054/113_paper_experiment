// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVerifier {
    function verifyProof(
        uint[2] calldata pA,
        uint[2][2] calldata pB,
        uint[2] calldata pC,
        uint[74] calldata pubSignals
    ) external view returns (bool);
}

contract Settlement {
    address public owner;
    address public verifier;

    event SettlementExecuted(address indexed caller, uint256 indexed roundId);
    event BillVerified(address indexed caller, bool indexed ok);

    constructor(address _verifier) {
        owner = msg.sender;
        verifier = _verifier;
    }

    function verifyBillOnly(
        uint[2] calldata pA,
        uint[2][2] calldata pB,
        uint[2] calldata pC,
        uint[74] calldata pubSignals
    ) external returns (bool) {
        bool ok = IVerifier(verifier).verifyProof(pA, pB, pC, pubSignals);
        emit BillVerified(msg.sender, ok);
        return ok;
    }

    function settle(uint256 roundId) external {
        emit SettlementExecuted(msg.sender, roundId);
    }
}
