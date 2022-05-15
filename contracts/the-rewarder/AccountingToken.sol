// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title AccountingToken
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 * @notice A limited pseudo-ERC20 token to keep track of deposits and withdrawals
 *         with snapshotting capabilities
 */
contract AccountingToken is ERC20Snapshot, AccessControl {
    /*Poveznica snapshot tokena s DAO
    You’ll notice this isn’t a “normal” ERC20 token, this is because we need to keep track of “snapshots.” Whenever a vote is proposed, we want to make sure that we use people's balances from X blocks ago, instead of whenever the proposal was made. This will reduce people buying and selling voting tokens whenever they think a vote they want to be a part of is coming up and will make sure the number of votes stays consistent.

    Once a “checkpoint” or a “snapshot” of people's tokens balances are calculated for a voting period, that’s it! You can’t buy more tokens after a vote is proposed and get more votes! You would have had to have already been holding the token */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor() ERC20("rToken", "rTKN") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(SNAPSHOT_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) external {
        /*NE MINTAMO KAO PRIJE CILI SUPPLY I TJT, OVDE MINTAMO KAD NAM ZATREBA, ISTA STVAR I SA BURN, TOTAL SUPPLY= trenutna suma na racunima korisnika */
        require(hasRole(MINTER_ROLE, msg.sender), "Forbidden");
        /*
        Creates amount tokens and assigns them to account, increasing the total supply.
        PRINCIP->Emits a transfer event with from set to the zero address.(isto kao i kad bi prije mintali obicni ERC20 token)
        uvjet-> ACCOUNT ODNOSNO to parametar ne smi bit ZERO ADRESS
        */
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        require(hasRole(BURNER_ROLE, msg.sender), "Forbidden");
        /*

            Destroys amount tokens from account, reducing the total supply.

            PRINCIP->Emits a transfer event with to set to the zero address.
        */
        _burn(from, amount);
    }

    function snapshot() external returns (uint256) {
        require(hasRole(SNAPSHOT_ROLE, msg.sender), "Forbidden");
        return _snapshot();
    }

    // Do not need transfer of this token
    function _transfer(address, address, uint256) internal pure override {
        revert("Not implemented");
    }

    // Do not need allowance of this token
    function _approve(address, address, uint256) internal pure override {
        revert("Not implemented");
    }
}