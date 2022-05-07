// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IReceiver {
    function receiveTokens(address tokenAddress, uint256 amount) external;
}

/**
 * @title UnstoppableLender
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract UnstoppableLender is ReentrancyGuard {

    IERC20 public immutable damnValuableToken;
    uint256 public poolBalance;

    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Token address cannot be zero");
        damnValuableToken = IERC20(tokenAddress);//pokazuje na mart contract od tokena, preko njega radimo transfere s tokenima i on sadrzi mapiranje adresa i balancea na tim adresama
    }

    function depositTokens(uint256 amount) external nonReentrant {
        require(amount > 0, "Must deposit at least one token");
        // Transfer token from sender. Sender must have first approved them.
        //je li ovde onda message.sender  adresa instance od contracta Unstopable lender tj kako ce se onda prenosit tokeni ako su svi na racunu od vlasnika tokena
        //msg.sender je deployer u test fileu?
        damnValuableToken.transferFrom(msg.sender, address(this), amount);
        poolBalance = poolBalance + amount;
    }

    function flashLoan(uint256 borrowAmount) external nonReentrant {
        require(borrowAmount > 0, "Must borrow at least one token");

        uint256 balanceBefore = damnValuableToken.balanceOf(address(this));
        require(balanceBefore >= borrowAmount, "Not enough tokens in pool");

        // Ensured by the protocol via the `depositTokens` function
        assert(poolBalance == balanceBefore);//kako tretirat kad nam neko transfera tokene na nas contract preko trasnfer funkcije od contracta od tokena a ne nase depositTokens?
        //ne mozemo dobit notifikaciju nikakvu od tog token contracta
        //onda maknit ovi assert i u slucaju da je drukcije onda postavit poolBalance na ovu vrijednost?
        //ili sprijecit da nam neko transfera tokene van nase depostiTokens funkcije-> to ne mozemo jer on operira na smart contractu od tokena?
        //je li se pozove ista kad nam neko transfera token neki fallback jel se poziva? ako da onda tu odbit takve transkacije
        
        damnValuableToken.transfer(msg.sender, borrowAmount);//DEFAULTNA ADRESA OD KOJEG SE UZIMA JE ADRESA UNSOTPABLELENDER SMART CONTRACTA JER CE TO BITI msg.sender u transfer funkciji od token smartcontracta
        
        IReceiver(msg.sender).receiveTokens(address(damnValuableToken), borrowAmount);
        
        uint256 balanceAfter = damnValuableToken.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Flash loan hasn't been paid back");
    }
}
