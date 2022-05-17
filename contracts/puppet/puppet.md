# Puppet
## Challenge description
 There's a huge lending pool borrowing Damn Valuable Tokens (DVTs), where you first need to deposit twice the borrow amount in ETH as collateral. The pool currently has 100000 DVTs in liquidity.

There's a DVT market opened in an Uniswap v1 exchange, currently with 10 ETH and 10 DVT in liquidity.

Starting with 25 ETH and 1000 DVTs in balance, you must steal all tokens from the lending pool. 
## Contracts
Besides the contract given to us in the contracts/puppet directory named `PuppetPool.sol`, an Uniswap V1 liquidity pool is also initialized for us to use. Its' most commonly used for decentralized trading.

In this case the pool consists of ETH/DVT (Ethereum/Damn Valuable Tokens). The `PuppetPool` contract is used for borrowing DVTs.

![Puppet contract](../../images/puppet.png)

Using the `PuppetPool` is fairly simple. We invoke the `borrow()` function with a borrow amount as an argument. In order for our borrowing to work we must send enough __ether__. Amount of __ether__ necessary is calculated on the contract by the `calculateDepositRequired()` function.

The function calculates its' current deposit amount by calling the Uniswap contract as an oracle for fetching the current ETH/DVT price (Basicly checking the balance of both pairs on the Uniswap contract).
## Vulnerability
## Attack
## TLDR