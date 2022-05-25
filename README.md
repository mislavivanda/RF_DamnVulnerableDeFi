![](cover.png)

# Table of contents
- ##[Introduction](#Introduction)
- ## [Closing words](#Closing-words)
- ## [Credits](#Credits)
- ## Challenges README
  - ### [Unstoppable](../../blob/latest-version-branch/contracts/unstoppable/README.md)
  - ### [Naive receiver](../../blob/latest-version-branch/contracts/naive-receiver/README.md)
  - ### [Truster](../../blob/latest-version-branch/contracts/truster/README.md)
  - ### [Side entrance](../../blob/latest-version-branch/contracts/side-entrance/README.md)
  - ### [The rewarder](../../blob/latest-version-branch/contracts/the-rewarder/README.md)
  - ### [Selfie](../../blob/latest-version-branch/contracts/selfie/README.md)
  - ### [Compromised](../../blob/latest-version-branch/contracts/compromised/README.md)
  - ### [Puppet](../../blob/latest-version-branch/contracts/puppet/README.md)
  - ### [Puppet v2](../../blob/latest-version-branch/contracts/puppet-v2/README.md)
  - ### [Free rider](../../blob/latest-version-branch/contracts/free-rider/README.md)
  - ### [Backdoor](../../blob/latest-version-branch/contracts/backdoor/README.md)
  - ### [Climber](../../blob/latest-version-branch/contracts/climber/README.md)
# Introduction
Since Bitcoin's initial release in 2009, a new paradigm of decentralization has started to incorporate in many fields as an alternative to previous traditional - centralized systems. Bitcoin was the pioneer of decentralization, but it also only supported decentralized money/cryptocurrency transfers with no other functionality.

In 2015. Ethereum blockhain was released which extended previous decentralized money transferring with **smart contracts** which provide capability of interacting with blockchain and executing different actions specified by programmer. This concept was revolutionary since it introduced an alternative for many things which could, until then, be only done by centralized authorities to whom we were forced to trust. We are talking about insurance policies, money exchanges, investments, loans, money balances, agreements between parties etc. All of this could now be done in a decentralized manner. Also, smart contracts not only provide decentralized alternative for centralized procedures but they also introduce tools for development of completely new concepts which were, before their occurrence, unimaginable(flash loans, tokens, NFTs etc.). **Welcome to the DeFi world**. 

Because of their previously mentioned large execution gulf, smart contracts introduced new high value markets which could be utilized by anyone. This was followed by massive popularity of decentralized paradigm followed by growth of community and other blockhains dedicated to improve current technical problems. Also, one of the biggest ideas which was derived from decentralization paradigm is integrating these concepts into World Wide Web and developing its new generation also known as **Web 3.0.**

Unfortunately, high value markets also attract individuals which try to utilize them in a way of exploiting flaws in design in order to make money. Since we are talking about financial market these flaws could cause catastrophic [**consequences**](https://decrypt.co/93874/biggest-defi-hacks-heists).

This combined with the fact that our contract code is stored on blockchain which is public(thus it can be read and inspected by everyone) and can not be modified(once we deploy our contract it stays on blochain forever), implies that programmers have huge responsibility to design and implement flawless contracts. In order to do that, attention must be paid on the security aspect. In fact, this should be the main/central part of smart contract development.

Truth is that all of us learn on mistakes which are sometimes expensive which is certainly the case in DeFi context. In order to emphasize security aspect of smart contract development there are tons of articles covering certain design flaws and interactive developer oriented ''games'' which provide challenges which are solved by exploiting contract security flaws and using them to hack specified DeFi implementations. Most popular ''games'' of this type are [**Damn Vulnerable DeFi**](https://www.damnvulnerabledefi.xyz/), [**Ethernaut**](https://ethernaut.openzeppelin.com/) and [**Capture the Ether**](https://capturetheether.com/).

In our case we will talk about [**Damn Vulnerable DeFi**](https://www.damnvulnerabledefi.xyz/) as one of the most popular smart contract ''wargames'' and *de facto* standard for exploiting smart contract security design flaws. It features flaws in a variety of DeFi concepts such as flash loans, price oracles, governance, NFTs, lending pools, smart contract wallets, timelocks etc.

Main goal of this project is to share our knowledge which we have obtained as part of solving [**Damn Vulnerable DeFi**](https://www.damnvulnerabledefi.xyz/) challenges which can serve as a nice tool to enhance your comprehension of various DeFi concepts and Solidity language. 

JavaScript testing code solutions and added smart contracts code(if required by challenge) are given for every challenge along with README file with in depth explanation of contract functionality, vulnerability, attack strategy and corresponding DeFi and Solidity language concepts which are featured in observed challenge. README files can be referenced from [**table of contents**](##Challenges-README).

>**Note**: We recommend that you always first try to solve the challenge by yourself and if you have difficulties cast an eye on our README's. Some challenges require more time to dive into and grasp their concepts so don't droop down if it takes a lot of time and you still didn't solve the challenge.

# Closing words
We can freely say that we are living in an exciting and historical moment in which we witness some of the most revolutionary concepts developed in human history. We have seen how smart contracts which seem perfectly secure at first glance in fact feature security flaws which could result in catastrophic consequences such as mentioned draining lending pool funds, [NAVEDI OVDE JOS 2 PRIMJERA IZ SVOJIH CHALLENGEA]. These challenges emphasize the role of security in smart contract development and justify the existance of professional smart contract audit services.

We hope that our project helped you to resolve all challenges and get into exiciting DeFi world full of opportunities.

At the end we wish you **HAPPY HACKING!**
# Credits
Many thanks to author [**@tinchoabbate**](https://twitter.com/tinchoabbate) for these incredible DeFi challenges which make you learn tons of new stuff on practical examples.

Visit [**damnvulnerabledefi.xyz**](https://damnvulnerabledefi.xyz) official page.
## Challenge solutions authors:
### **Challenges #1 - #6**:  [**@mislavivanda**](https://github.com/mislavivanda)

### **Challenges #7 - #12**: [**@matejdrazic**](https://github.com/matejdrazic)
