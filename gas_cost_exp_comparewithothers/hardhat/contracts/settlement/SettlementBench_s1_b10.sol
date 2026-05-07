// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVerifierS1B10 {
    function verifyProof(
        uint[2] calldata pA,
        uint[2][2] calldata pB,
        uint[2] calldata pC,
        uint[38] calldata pubSignals
    ) external view returns (bool);
}

contract SettlementBench_s1_b10 {
    address public immutable owner;
    address public immutable verifier;

    event DepositReceived(address indexed from, uint256 amount);
    event PayoutExecuted(address indexed recipient, uint256 amount);

    error OnlyOwner();
    error InvalidVerifier();
    error InsufficientBalance();
    error TransferFailed();

    constructor(address _verifier) payable {
        if (_verifier == address(0)) revert InvalidVerifier();
        owner = msg.sender;
        verifier = _verifier;
    }

    receive() external payable {
        emit DepositReceived(msg.sender, msg.value);
    }

    function deposit() external payable {
        emit DepositReceived(msg.sender, msg.value);
    }

    function benchmarkVerifyOnly(
        uint[2] calldata pA,
        uint[2][2] calldata pB,
        uint[2] calldata pC,
        uint[38] calldata pubSignals
    ) external returns (bool ok) {
        ok = IVerifierS1B10(verifier).verifyProof(pA, pB, pC, pubSignals);
    }

    function benchmarkPayoutOnly(address payable recipient, uint256 amount) external {
        if (msg.sender != owner) revert OnlyOwner();
        if (address(this).balance < amount) revert InsufficientBalance();

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) revert TransferFailed();

        emit PayoutExecuted(recipient, amount);
    }
}
