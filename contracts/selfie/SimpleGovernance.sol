// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableTokenSnapshot.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SimpleGovernance
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SimpleGovernance {

    using Address for address;
    
    struct GovernanceAction {
        address receiver;
        bytes data;
        uint256 weiAmount;
        uint256 proposedAt;//kad je predlozena
        uint256 executedAt;//prati je li executana ikako prije
    }
    
    DamnValuableTokenSnapshot public governanceToken;

    mapping(uint256 => GovernanceAction) public actions;
    uint256 private actionCounter;
    uint256 private ACTION_DELAY_IN_SECONDS = 2 days;

    event ActionQueued(uint256 actionId, address indexed caller);
    event ActionExecuted(uint256 actionId, address indexed caller);

    constructor(address governanceTokenAddress) {//governance token je isto DVT token-> za dobit voting/action mogucnosti trebaju nam DVT tokeni
        require(governanceTokenAddress != address(0), "Governance token cannot be zero address");
        governanceToken = DamnValuableTokenSnapshot(governanceTokenAddress);
        actionCounter = 1;
    }
    
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256) {
        require(_hasEnoughVotes(msg.sender), "Not enough votes to propose an action");
        require(receiver != address(this), "Cannot queue actions that affect Governance");//ne mozemo pozivat funkcije na governance contractu

        uint256 actionId = actionCounter;

    /*Memory and calldata mean the variable will only exist for the transaction, storage will be saved FOREVER */
        GovernanceAction storage actionToQueue = actions[actionId];//pohrani u storage objekt tipa GovernanaceAction, actionToQueueu je referecna koja pokazuje na njega -> preko nje mijenjamo taj niz
        actionToQueue.receiver = receiver;
        actionToQueue.weiAmount = weiAmount;
        actionToQueue.data = data;
        actionToQueue.proposedAt = block.timestamp;

        actionCounter++;//broji akcije

        emit ActionQueued(actionId, msg.sender);
        return actionId;
    }

    function executeAction(uint256 actionId) external payable {
        require(_canBeExecuted(actionId), "Cannot execute this action");
        
        GovernanceAction storage actionToExecute = actions[actionId];//
        actionToExecute.executedAt = block.timestamp;

        actionToExecute.receiver.functionCallWithValue(//pozovi akciju odnosno funkciju na kontraktu s recevier adresom i trasfneriraj weiAmount tokena
            actionToExecute.data,
            actionToExecute.weiAmount// transferring value wei to target
        );

        emit ActionExecuted(actionId, msg.sender);
    }

    function getActionDelay() public view returns (uint256) {
        return ACTION_DELAY_IN_SECONDS;
    }

    /**
     * @dev an action can only be executed if:
     * 1) it's never been executed before and
     * 2) enough time has passed since it was first proposed
     */
    function _canBeExecuted(uint256 actionId) private view returns (bool) {
        GovernanceAction memory actionToExecute = actions[actionId];
        return (
            actionToExecute.executedAt == 0 &&
            (block.timestamp - actionToExecute.proposedAt >= ACTION_DELAY_IN_SECONDS)
        );
    }
    
    function _hasEnoughVotes(address account) private view returns (bool) {//ima pravo pozvat akciju ako imas vise od 50% ukupnih sredstava DVT tokena
        uint256 balance = governanceToken.getBalanceAtLastSnapshot(account);
        uint256 halfTotalSupply = governanceToken.getTotalSupplyAtLastSnapshot() / 2;
        return balance > halfTotalSupply;
    }
}
