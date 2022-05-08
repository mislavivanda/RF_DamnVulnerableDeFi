// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SideEntranceLenderPool {
    using Address for address payable;//mogucnost pizivanja Address utlity funkcija na tipivima podataka tipa address payable

    mapping (address => uint256) private balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).sendValue(amountToWithdraw);//wrapper za sigurniju solidity trasnfer funkciju, transferamo na adrsu koja poiva funkciju a from=msg.sender odakle se poziva funkcija, u ovom slucaju to je nas pool contract
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        require(balanceBefore >= amount, "Not enough ETH in balance");
        
        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();/*When a contract wants to call another contract and send Ether, it can set the amount with the special value syntax in curly brackets. For example, if we have a SimpleBank sb field in another contract, we can call sb.deposit{value: amount}() to deposit a given amount. Note that the curly brackets must come between the function name and its parameter list. */

        require(address(this).balance >= balanceBefore, "Flash loan hasn't been paid back");        
    }
}
 