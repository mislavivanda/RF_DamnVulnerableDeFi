const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] The rewarder', function () {

    let deployer, alice, bob, charlie, david, attacker;
    let users;

    const TOKENS_IN_LENDER_POOL = ethers.utils.parseEther('1000000'); // 1 million tokens

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        [deployer, alice, bob, charlie, david, attacker] = await ethers.getSigners();
        users = [alice, bob, charlie, david];

        const FlashLoanerPoolFactory = await ethers.getContractFactory('FlashLoanerPool', deployer);
        const TheRewarderPoolFactory = await ethers.getContractFactory('TheRewarderPool', deployer);
        const DamnValuableTokenFactory = await ethers.getContractFactory('DamnValuableToken', deployer);
        const RewardTokenFactory = await ethers.getContractFactory('RewardToken', deployer);
        const AccountingTokenFactory = await ethers.getContractFactory('AccountingToken', deployer);
        const RewardTokenAttackerContractFactory = await ethers.getContractFactory('RewardTokenAttacker',attacker)

        this.liquidityToken = await DamnValuableTokenFactory.deploy();
        this.flashLoanPool = await FlashLoanerPoolFactory.deploy(this.liquidityToken.address);

        // Set initial token balance of the pool offering flash loans
        await this.liquidityToken.transfer(this.flashLoanPool.address, TOKENS_IN_LENDER_POOL);

        this.rewarderPool = await TheRewarderPoolFactory.deploy(this.liquidityToken.address);
        /*REWARD TOKEN VEĆ NAPRAVLJEN KOD DEPLOYANJA rewarderPoola -> ZATO GA NE DEPLOYAMO OPET NEGO GA POSTAVIMO NA VEĆ KREIRANU INSTANCU IZ this.rewarderPool contracta */
        this.rewardToken = await RewardTokenFactory.attach(await this.rewarderPool.rewardToken());//Returns a new instance of the Contract attached to a new address. This is useful if there are multiple similar or identical copies of a Contract on the network and you wish to interact with each of them
        this.accountingToken = await AccountingTokenFactory.attach(await this.rewarderPool.accToken());
        this.attackerContract=await RewardTokenAttackerContractFactory.deploy(TOKENS_IN_LENDER_POOL,this.rewarderPool.address,this.flashLoanPool.address,this.liquidityToken.address,this.rewardToken.address)

        // Alice, Bob, Charlie and David deposit 100 tokens each
        for (let i = 0; i < users.length; i++) {
            const amount = ethers.utils.parseEther('100');
            /*msg.sender je defaultno na adresi od deployera */
            await this.liquidityToken.transfer(users[i].address, amount);
            await this.liquidityToken.connect(users[i]).approve(this.rewarderPool.address, amount);/*APPROVAJ REWARD POOLU DA MOZE TROSIT DO amount TOKENA -> bitno kako bi se mogao koristit trasnfer u idućoj .deposit() funkciji */
            await this.rewarderPool.connect(users[i]).deposit(amount);
            expect(
                await this.accountingToken.balanceOf(users[i].address)
            ).to.be.eq(amount);
        }
        expect(await this.accountingToken.totalSupply()).to.be.eq(ethers.utils.parseEther('400'));/*TOLIKO SMO IH MINTALI -> ZA SVAKI  */
        expect(await this.rewardToken.totalSupply()).to.be.eq('0');/*reward token se isto minta po potrebi kad se isplacuju rewardovi */

        // Advance time 5 days so that depositors can get rewards
        await ethers.provider.send("evm_increaseTime", [5 * 24 * 60 * 60]); // 5 days
        
        // Each depositor gets 25 reward tokens
        for (let i = 0; i < users.length; i++) {
            await this.rewarderPool.connect(users[i]).distributeRewards();/*TRANSAKCIJA */
            expect(
                await this.rewardToken.balanceOf(users[i].address)
            ).to.be.eq(ethers.utils.parseEther('25'));
        }
        expect(await this.rewardToken.totalSupply()).to.be.eq(ethers.utils.parseEther('100'));

        // Attacker starts with zero DVT tokens in balance
        expect(await this.liquidityToken.balanceOf(attacker.address)).to.eq('0');
        
        // Two rounds should have occurred so far -> prva kod kreiranja a druga nakon sta je proslo 5 dana
        expect(
            await this.rewarderPool.roundNumber()
        ).to.be.eq('2');
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE */
        await ethers.provider.send("evm_increaseTime", [5 * 24 * 60 * 60]); // 5 days
        await this.attackerContract.connect(attacker).receiveRewardTokens()
    });

    after(async function () {
        /** SUCCESS CONDITIONS */
        
        // Only one round should have taken place
        expect(
            await this.rewarderPool.roundNumber()
        ).to.be.eq('3');

        // Users should get neglegible rewards this round -> DOBIT ĆE OPET 25?
        for (let i = 0; i < users.length; i++) {
            await this.rewarderPool.connect(users[i]).distributeRewards();
            let rewards = await this.rewardToken.balanceOf(users[i].address);
            
            // The difference between current and previous rewards balance should be lower than 0.01 tokens
            let delta = rewards.sub(ethers.utils.parseEther('25'));
            expect(delta).to.be.lt(ethers.utils.parseUnits('1', 16))
        }
        
        // Rewards must have been issued to the attacker account
        expect(await this.rewardToken.totalSupply()).to.be.gt(ethers.utils.parseEther('100'));
        let rewards = await this.rewardToken.balanceOf(attacker.address);

        // The amount of rewards earned should be really close to 100 tokens-> ZBOG FORMULE KAKO SE RACUNAJU REWARDOVI NE MOZEMO DOĆ DO 100 NEGO LIMES IDE U 100
        let delta = ethers.utils.parseEther('100').sub(rewards);
        expect(delta).to.be.lt(ethers.utils.parseUnits('1', 17));

        // Attacker finishes with zero DVT tokens in balance
        expect(await this.liquidityToken.balanceOf(attacker.address)).to.eq('0');
    });
});
