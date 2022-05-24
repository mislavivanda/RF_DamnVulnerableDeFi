# Truster
# Description
 More and more lending pools are offering flash loans. In this case, a new pool has launched that is offering flash loans of DVT tokens for free.
 
Currently the pool has **1 million DVT tokens** in balance. And you have **nothing**.

But don't worry, you might be able to **take them all** from the pool. **In a single transaction**.
# Contracts
- `TrusterLenderPool.sol`: generous contract which offers flash loans without charging any fee. Flahs loans are offered through `flashLoan()` method which transfers requested amount of DVTs to borrower address if it doesn't exceed pool amount. Flash loan concept which includes calling certain smart contract method specified by borrower is supported by providing flexibility to borrower in a way he can choose contract address with `target` parameter and its method signature with `data` parameter. This procedure is supported by **OpenZeppelin's** `functionCall()` method specified inside [**`Address`**](https://docs.openzeppelin.com/contracts/3.x/api/utils#Address) utility. At the end, method checks if borrowed amount was repaid.

    >**Note**: You probably noticed uncommon `calldata` keyword specified for `data` parameter. This is the right place to introduce Solidity's `storage`, `memory` and `calldata` keywords used for contract memory managment which, when properly used, can have huge impact on gas fee amount when invoking contract methods:
    
    > - `storage`: saving data in `storage` variable means that data will exist forever in contract memory. For example, it can be used to save contract state data.
    
    > - `memory`: saving data in `memory` variable means it will exist only during current transaction with possibility to modify variable values.
    
    > - `calldata`: like `memory`, `calldata` variable exists only during current transaction but its value is **immutable** which corresponds with lower gas prices. 
    
- `AttackerApproveTokensContract.sol`: in order to exploit `TrusterLenderPool.sol` vulnerability we need to interact with `TrusterLenderPool.sol` so we need to deploy our contract. Whole logic of our attack lays inside `drainPoolFunds()` method which can be only called by contract owner i.e. us. Detailed explanation of method logic can be found in [**Attack**](#Attack) section.

# Vulnerability
If we examine `TrusterLenderPool.sol` `flashLoan()` method we notice that it is almost same as one from [**Unstoppable**](../../contracts/unstoppable/README.md) challenge with removed `assert()` vulnerability and different borrower method invocation. On first sight we could conclude that this method is perfectly secure, which ofcourse is not the case. 

Contract vulnerability lays in the way borrower method is invoked combined with Solidity's `msg.sender` value setting. For better attack comprehension we will first explain in short terms how is `msg.sender` value determined when invoking method. 

When smart contract method is invoked from **EOA**(***E**xternally **O**wned **A**ccount*) `msg.sender` value is set to EOA's address. When smart contract method is invoked from another smart contract `msg.sender` value is set to address of contract from which method is being invoked.

Previously, borrower method needed to follow signature specified in interface and it was invoked from lender contract which delegated control to borrower contract. In this case, `msg.sender` value inside borrower method was address of pool contract.

In current `flashLoan()` implementation borrower has more flexibility as he can define `address` of any contract he wants with `target` parameter paired with method signature he wants to invoke on given contract specified by `data` parameter. 

Value of `msg.sender` inside function specified by `data` parameter is also set to pool address.

So we ask ourselves: *is there any method on some contract which we could invoke and exploit `msg.sender` value setting on pool address?*

Short answer to this questions is **yes!**, and long answer is mentioned inside [**Attack**](#Attack) chapter.

>**Note**: At first glance you could probably ask yourselft: *Couldn't we do the same thing in previous cases since `msg.sender` value is same in both method invocations?* 
>
>If you tried to invoke `approve()` method inside borrower contract method defined in lender interface you should notice that in this case `msg.sender` value in `approve()` method wouldn't be address of pool contract, but the address of borrower contract so we couldn't approve us to spend pool tokens. 
# Attack
As previously explained in [**Vulnerability**](#Vulnerability) chapter, our goal is to take advantage of `TrusterLenderPool.sol` contract `flashLoan()` method flexibility on borrower method invocation. 

Using this flexibility combined with our knowledge of `msg.sender` values we can specifiy DVT token contract address as `target` parameter and invoke ERC20 `approve()` method as part of `data` parameter with `spender` address set to our contract address and amount set to whole `TrusterLenderPool.sol` pool amount. 

Since this method will be invoked directly inside `TrusterLenderPool.sol` contract, `msg.sender` method will be set to pool address so the meaning ot this action would be: **pool contract approves us to spend all of its tokens**. 

We can do this in a single transaction by invoking `drainPoolFunds()` method on our deployed `AttackerApproveTokensContract.sol` contract. Inside this method we call `TrusterLenderPool.sol` `flashLoan()` method and set our borrowed value to be 0 since we don't have any DVTs and `target` and `data` parameters as previously mentioned. 

In order to conform with `bytes` data type we encode `approve()` method signature by using Solidity's native `abi.encodeWithSignature()` method which converts specified method signature and parameters into bytes form. 

After `flashLoan()` invocation we have successfully been approved to spend all pool funds. After approval our contract can do anything we want with pool tokens and what we want is to transfer obtained DVTs to our/owner address which we perform by calling ERC20 `transferFrom()` method where `spender` is our `AttackerApproveTokensContract.sol` contract, `sender` is `TrusterLenderPool.sol`, `receiver` is our address and `amount` is whole pool amount.

Method implementation is:

![`drainPoolFunds()` method implementation](../../images/truster/truster.PNG)
# Summary
- Deploy contract
- Inside single transaction:
    - Borrow 0 DVTs in flash loan while specifying `target` and `data` parameters in a way which makes pool to approve us its whole amount of DVTs to spend
    - Transfer obtained tokens from pool address to our address
