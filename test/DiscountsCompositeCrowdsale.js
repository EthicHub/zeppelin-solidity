import ether from './helpers/ether'
import {advanceBlock} from './helpers/advanceToBlock'
import {increaseTimeTo, duration} from './helpers/increaseTime'
import latestTime from './helpers/latestTime'

const BigNumber = web3.BigNumber

const should = require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const CompositeCrowdsale = artifacts.require('CompositeCrowdsale')
const FixedPoolTokenDistribution = artifacts.require('FixedPoolTokenDistributionStrategy')
const FixedPoolDiscountsTokenDistribution = artifacts.require('FixedPoolDiscountsTokenDistributionStrategy')
//const FixedPoolWithDiscountsTokenDistribution = artifacts.require('FixedPoolWithDiscountsTokenDistributionStrategy')
const Token = artifacts.require('ERC20')

const SimpleToken = artifacts.require('SimpleToken')

contract('CompositeCrowdsale', function ([_, investor, wallet]) {

  const RATE = new BigNumber(4000);

  before(async function() {
    //Advance to the next block to correctly read time in the solidity "now" function interpreted by testrpc
    await advanceBlock();
  })

  describe('Fixed Discounts Pool Distribution', function () {

    beforeEach(async function () {
      this.startTime = latestTime() + duration.weeks(1);
      console.log("*** Start Time: " + this.startTime);
      this.endTime = this.startTime + duration.weeks(5);
      console.log("*** End Time: " + this.endTime);
      this.afterEndTime = this.endTime + duration.seconds(1);
      console.log("*** After End Time: " + this.afterEndTime);

      const fixedPoolToken = await SimpleToken.new();
      const totalSupply = await fixedPoolToken.totalSupply();
      this.tokenDistribution = await FixedPoolDiscountsTokenDistribution.new(fixedPoolToken.address);
      await fixedPoolToken.transfer(this.tokenDistribution.address, totalSupply);
      this.crowdsale = await CompositeCrowdsale.new(this.startTime, this.endTime, RATE, wallet, this.tokenDistribution.address)
      this.token = Token.at(await this.tokenDistribution.getToken.call());
    })

    it('should calculate tokens after first period', async function () {
      await increaseTimeTo(this.startTime)
      const investmentAmount = ether(0.000000000000000001);
      console.log("*** Amount: " + investmentAmount);
      let tokens = await this.tokenDistribution.calculateTokenAmount(investmentAmount, RATE).should.be.fulfilled;
      console.log("*** COMPOSITION Tokens: " + tokens);
      let tx = await this.crowdsale.buyTokens(investor, {value: investmentAmount, from: investor}).should.be.fulfilled;
      console.log("*** COMPOSITION FIXED POOL: " + tx.receipt.gasUsed + " gas used.");
    })

    it('should calculate tokens after second period', async function () {
      await increaseTimeTo(this.startTime + duration.weeks(2))
      const investmentAmount = ether(0.000000000000000001);
      console.log("*** Amount: " + investmentAmount);
      let tokens = await this.tokenDistribution.calculateTokenAmount(investmentAmount, RATE).should.be.fulfilled;
      console.log("*** COMPOSITION Tokens: " + tokens);
      let tx = await this.crowdsale.buyTokens(investor, {value: investmentAmount, from: investor}).should.be.fulfilled;
      console.log("*** COMPOSITION FIXED POOL: " + tx.receipt.gasUsed + " gas used.");
    })

    it('should calculate tokens after thrid period', async function () {
      await increaseTimeTo(this.startTime + duration.weeks(4))
      const investmentAmount = ether(0.000000000000000001);
      console.log("*** Amount: " + investmentAmount);
      let tokens = await this.tokenDistribution.calculateTokenAmount(investmentAmount, RATE).should.be.fulfilled;
      console.log("*** COMPOSITION Tokens: " + tokens);
      let tx = await this.crowdsale.buyTokens(investor, {value: investmentAmount, from: investor}).should.be.fulfilled;
      console.log("*** COMPOSITION FIXED POOL: " + tx.receipt.gasUsed + " gas used.");
    })
  });

  describe('Fixed Pool Distribution', function () {

    beforeEach(async function () {
      this.startTime = latestTime() + duration.weeks(1);
      this.endTime = this.startTime + duration.weeks(1);
      this.afterEndTime = this.endTime + duration.seconds(1);

      const fixedPoolToken = await SimpleToken.new();
      const totalSupply = await fixedPoolToken.totalSupply();
      this.tokenDistribution = await FixedPoolTokenDistribution.new(fixedPoolToken.address);
      await fixedPoolToken.transfer(this.tokenDistribution.address, totalSupply);
      this.crowdsale = await CompositeCrowdsale.new(this.startTime, this.endTime, RATE, wallet, this.tokenDistribution.address)
      this.token = Token.at(await this.tokenDistribution.getToken.call());
    })

    beforeEach(async function () {
      await increaseTimeTo(this.startTime)
    })

    it('should buy tokens and compensate contributors after the sale', async function () {
      const investmentAmount = ether(0.000000000000000001);
      console.log("*** Amount: " + investmentAmount);
      let tokens = await this.tokenDistribution.calculateTokenAmount(investmentAmount, RATE).should.be.fulfilled;
      console.log("*** COMPOSITION Tokens: " + tokens);
      let tx = await this.crowdsale.buyTokens(investor, {value: investmentAmount, from: investor}).should.be.fulfilled;
      console.log("*** COMPOSITION FIXED POOL: " + tx.receipt.gasUsed + " gas used.");

      await increaseTimeTo(this.afterEndTime);
      await this.tokenDistribution.compensate(investor).should.be.fulfilled;
      const totalSupply = await this.token.totalSupply();
      (await this.token.balanceOf(investor)).should.be.bignumber.equal(totalSupply);

    })


  });

})
