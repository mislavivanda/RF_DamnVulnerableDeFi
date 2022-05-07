// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title FlashLoanReceiver
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract FlashLoanReceiverFix {
    using Address for address payable;

    address payable private pool;
    address private owner;

    constructor(address payable poolAddress) {
        pool = poolAddress;
        owner=msg.sender;
    }

    // Function called by the pool during flash loan
    //PRIJE OVOG POZIVA DOBILI SMO VEC SREDSTVA KOJA SMO ZATRAZILI U FLASH LOANU -> VRATIMO S KAMATON
    function receiveEther(uint256 fee) public payable {
        require(msg.sender == pool, "Sender must be pool");
        //POTREBAN DODATNI REQUIRE KOJI CE GLEDAT JE LI ONAJ KO JE POZVA .flashLoan od poola owner od ovog contracta
        require(tx.origin==owner,"Transaction initiator must be owner of contract");
        //inace se ovi tx.orogin ne preporuca zbog mogucnosti phishing napada ->ako nas contract interaktira s nekin drugin contracton koji ce rekruzivno/fallback poizvat nas pocetni contract onda ce tx.orogin bit nas pocetni contract i prolazit ce nan uvjet
        //ovde nema fallback funkcije ou lender poolu tako da nema rekurzivnog pozivanja i drainanja dodatnih fundova iz ovog contracta
        //ovako moze svako pozivat
        uint256 amountToBeRepaid = msg.value + fee;

        require(address(this).balance >= amountToBeRepaid, "Cannot borrow that much");
        
        _executeActionDuringFlashLoan();
        
        // Return funds to pool -> AKO IMAMO DOVOLJNO SREDSTAVA ONDA PLATI POOLU S KAMATON
        pool.sendValue(amountToBeRepaid);//ovde fali recipient?
        //pool bi treba dobit 
    }

    // Internal function where the funds received are used -> ne radi nista?
    function _executeActionDuringFlashLoan() internal { }

    // Allow deposits of ETH -> CONTRCT MORA IMAT RECEIVE() PAYABLE FUNKCIJU KAKO BI NA NJEGA MOGLI DEPLOYAT 
    receive () external payable {}
}