import ether from './helpers/ether';
import {advanceBlock} from './helpers/advanceToBlock';
import {increaseTimeTo, duration} from './helpers/increaseTime';
import latestTime from './helpers/latestTime';
import EVMThrow from './helpers/EVMThrow';

const BigNumber = web3.BigNumber;

const should = require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

const CompositeCrowdsale = artifacts.require('CompositeCrowdsale');
const Token = artifacts.require('ERC20');

const SimpleToken = artifacts.require('SimpleToken');
const Distribution = artifacts.require('./helpers/ConfigurableFixedPoolDiscountsDistribution');

contract('CompositeCrowdsale', function ([_, investor, wallet]) {

  const RATE = new BigNumber(1000);

  before(async function() {
    //Advance to the next block to correctly read time in the solidity "now" function interpreted by testrpc
    await advanceBlock();
  })

  describe('Fixed Pool Discounted Distribution', function () {

    beforeEach(async function () {
      this.startTime = latestTime() + duration.weeks(1);
      this.endTime = this.startTime + duration.weeks(1);
      this.afterEndTime = this.endTime + duration.seconds(1);
      this.fixedPoolToken = await SimpleToken.new();

      await increaseTimeTo(this.startTime)
    })

    it('should set crowdsale in distribution', async function () {
      const tokenDistribution = await Distribution.new(this.fixedPoolToken.address);
      tokenDistribution.addInterval(this.startTime, 22);
      this.startTime + duration.seconds(5);
      const crowdsale = await CompositeCrowdsale.new(this.startTime, this.endTime, RATE, wallet, tokenDistribution.address);
      await tokenDistribution.getCrowdsale().should.eventually.equal(crowdsale.address);

      var intervals = await tokenDistribution.getIntervals();
    })

    it('should fail when setting a distribution without intervals');
    // it('should fail when setting a distribution without intervals', async function () {
    //   const tokenDistribution = await Distribution.new(this.fixedPoolToken.address);
    //   this.startTime + duration.seconds(5);
    //   await CompositeCrowdsale.new(this.startTime, this.endTime, RATE, wallet, tokenDistribution.address).should.be.rejectedWith(EVMThrow);
    // })

    it('should fail when setting a distribution with intervals with discount < 0');

    it('should fail when setting a distribution with first interval ending before crowdsale.startTime');

    it('should fail when setting a distribution with last interval ending after crowdsale.endTime');

    it('should calcutate token with the first period discount', async function () {
      const tokenDistribution = await Distribution.new(this.fixedPoolToken.address);
      tokenDistribution.addInterval(this.startTime, 30);
      this.startTime + duration.seconds(5);
      const crowdsale = await CompositeCrowdsale.new(this.startTime, this.endTime, RATE, wallet, tokenDistribution.address);

      const investmentAmount = ether(1);
      let tx = await crowdsale.buyTokens(investor, {value: investmentAmount, from: investor}).should.be.fulfilled;

      await increaseTimeTo(this.afterEndTime);
      await tokenDistribution.compensate(investor).should.be.fulfilled;

      const token = Token.at(await tokenDistribution.getToken.call());
      const totalSupply = await token.totalSupply();
      console.log(await token.balanceOf(investor));
      (await token.balanceOf(investor)).should.be.bignumber.equal(totalSupply);
    })

    it('should distribute tokens with the second period discount');

    it('should distribute tokens with no after last period');


  });

});
