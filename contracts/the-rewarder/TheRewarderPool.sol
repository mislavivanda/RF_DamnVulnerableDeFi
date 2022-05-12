// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./RewardToken.sol";
import "../DamnValuableToken.sol";
import "./AccountingToken.sol";

/**
 * @title TheRewarderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)

 */
contract TheRewarderPool {

    // Minimum duration of each round of rewards in seconds
    uint256 private constant REWARDS_ROUND_MIN_DURATION = 5 days;

    uint256 public lastSnapshotIdForRewards;
    uint256 public lastRecordedSnapshotTimestamp;

    mapping(address => uint256) public lastRewardTimestamps;

    // Token deposited into the pool by users
    DamnValuableToken public immutable liquidityToken;

    // Token used for internal accounting and snapshots
    // Pegged 1:1 with the liquidity token
    AccountingToken public accToken;//ZA PRACENJE KOLIKO KO IMA SREDSTAVA-> 1DVT=1ACCOUNTING TOKEN
    
    // Token in which rewards are issued
    RewardToken public immutable rewardToken;

    // Track number of rounds
    uint256 public roundNumber;

    constructor(address tokenAddress) {
        // Assuming all three tokens have 18 decimals
        liquidityToken = DamnValuableToken(tokenAddress);
        accToken = new AccountingToken();
        rewardToken = new RewardToken();

        _recordSnapshot();
    }

    /**
     * @notice sender must have approved `amountToDeposit` liquidity tokens in advance
     */
    function deposit(uint256 amountToDeposit) external {
        require(amountToDeposit > 0, "Must deposit tokens");
        
        accToken.mint(msg.sender, amountToDeposit);/*accToken se minta prije nego se provjeri imamo li sredstava u require() ali svjd je jer ce se sve revertat ako pukne neki require */
        distributeRewards();

        require(
            liquidityToken.transferFrom(msg.sender, address(this), amountToDeposit),"Puka deposit"
        );
    }

    function withdraw(uint256 amountToWithdraw) external {
        accToken.burn(msg.sender, amountToWithdraw);/*WITHDRAWAJ BEZ PROVIZIJE SVOJA SREDSTVA*/
        /*NEMA PROVJERE JEL IMA DOVOLJNO-> ako nema puknit ce transfer i revertat pa ce se sve ponistit */
        require(liquidityToken.transfer(msg.sender, amountToWithdraw),"PUka withdraw");
    }

    function distributeRewards() public returns (uint256) {
        uint256 rewards = 0;

        if(isNewRewardsRound()) {/*SVAKO 5 DANA SE ISPLACUJU REWARDOVI -> KAD U POČETKU DEPOSITAJU SVI NEĆE SE ISPLATIT JER JE POČETNI SNAPSHOT UZET U TRENUTKU KRIERANJA CONTRACTA U CONSTRUCTORU-> IDUCA ISPLATA ĆE BITI 5 DANA NAKON KREIRANJA -> KAD SE PRVOME PODILI REWARD lastRecordedSnapshotTimestamp CE SE POSTAVIT NA NJEGA I CEKAT ĆE SE ONDA OPET OD TOG TRENUTKA 5 DANA */
            _recordSnapshot();
        }
        //OVDE SE UVIK RADI DISTRIBUTE NEOVISNO JE LI PROSLO 5 DANA-> ZNACI LI TO DA CE SE UVIK ISPLATIT REWARD KAD SE POZOVE OVA FUNKCIJHA -> NE 
        //-> lastRewardTimestamps[ADRESA] ĆE IMAT POHRANJEN TIMESTAMP KADA JE NETKO POVUKAO REWARDOVE -> MOZE IH POVUC SAMO JEDNOM U JEDNOJ RUNDI -> MOZE IH POVUC SAMO KAD MU TIMESTAMP NE UPADA U TRENUTNU RUNDU -> SPRIJECENO DUPLICIRANO POVLACENJE
        
        uint256 totalDeposits = accToken.totalSupplyAt(lastSnapshotIdForRewards);
        uint256 amountDeposited = accToken.balanceOfAt(msg.sender, lastSnapshotIdForRewards);

        if (amountDeposited > 0 && totalDeposits > 0) {
            rewards = (amountDeposited * 100 * 10 ** 18) / totalDeposits;//PO OVOJ LOGOCI CE ALICE,BOB,CHARLIE,DAVID DOBIT 100*100/400=25 REWARD TOKENA

            if(rewards > 0 && !_hasRetrievedReward(msg.sender)) {
                rewardToken.mint(msg.sender, rewards);
                lastRewardTimestamps[msg.sender] = block.timestamp;/*zapisi kad je koji user zadnje dobija rewardove */
            }
        }

        return rewards;     
    }

    function _recordSnapshot() private {
        lastSnapshotIdForRewards = accToken.snapshot();/*ovi snapshot govori koliko je ko u trenutku zahtjeva imao tokena u poolu -> na ovi nacin ne moze on kad dode isplata depositat 100000 tokena koji ce mu uc u obracun nego mu u obtracun ulazu sta je ima dotad */
        lastRecordedSnapshotTimestamp = block.timestamp;
        roundNumber++;
    }

    function _hasRetrievedReward(address account) private view returns (bool) {
        return (
            lastRewardTimestamps[account] >= lastRecordedSnapshotTimestamp &&
            lastRewardTimestamps[account] <= lastRecordedSnapshotTimestamp + REWARDS_ROUND_MIN_DURATION
        );
    }

    function isNewRewardsRound() public view returns (bool) {/*AKO SMO USLI U INTERVAL NOVE RUNDE KOD POZIVA FUNKCIJE-> AZURIRAJ I POSTAVI NOVU RUNDU */
        return block.timestamp >= lastRecordedSnapshotTimestamp + REWARDS_ROUND_MIN_DURATION;
    }
}
