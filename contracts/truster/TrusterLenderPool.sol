// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title TrusterLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract TrusterLenderPool is ReentrancyGuard {

    using Address for address;

    IERC20 public immutable damnValuableToken;

    constructor (address tokenAddress) {
        damnValuableToken = IERC20(tokenAddress);
    }

    function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data//podaci koji sadrze naziv funkcije na contractu kojeg pozivamo i argumente
    )
        external
        nonReentrant
    {//uveca counter za 1 kod prvog ulaza, osigurava da se funkcija poziva samo 1 za vrijeme jedne transakcije, nema vise poziva jer ako idemo pozvat opet rekuzirvno iz drugog contracta sluzit ce da je counter 1 i nece dopustit dalje
        uint256 balanceBefore = damnValuableToken.balanceOf(address(this));
        require(balanceBefore >= borrowAmount, "Not enough tokens in pool");
        
        //nije dozvoljen reentrancy atack a i on ne bi uspio jer kad bi ispraznili sve doli bi balanceAfter bio 0 a balance before neka druga vrijednost pa bi se ponistilo sve
        damnValuableToken.transfer(borrower, borrowAmount);
        target.functionCall(data);//sIGURNIJI NACIN POZIVA SOLIDTY call funkcije
        //Solidity call funkcija -> which can be used to call public and external functions on contracts. It can also be used to transfer ether to addresses.

        uint256 balanceAfter = damnValuableToken.balanceOf(address(this));
        //potrebno da je vracen uzeti iznos -> nema feea/kamate u ovom slucaju
        //ako nije vracen -> prekini transakciju-> revertaj sve
        require(balanceAfter >= balanceBefore, "Flash loan hasn't been paid back");
    }

}
