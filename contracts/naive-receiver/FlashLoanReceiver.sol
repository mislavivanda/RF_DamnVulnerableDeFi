// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title FlashLoanReceiver
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract FlashLoanReceiver {
    using Address for address payable;//mogucnost pizivanja Address utlity funkcija na tipivima podataka tipa address payable

    address payable private pool;

    constructor(address payable poolAddress) {
        pool = poolAddress;
    }

    // Function called by the pool during flash loan
    //PRIJE OVOG POZIVA DOBILI SMO VEC SREDSTVA KOJA SMO ZATRAZILI U FLASH LOANU -> VRATIMO ZATRAZENI S KAMATON U ZADNJOJ LINIJI
    function receiveEther(uint256 fee) public payable {
        require(msg.sender == pool, "Sender must be pool");

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