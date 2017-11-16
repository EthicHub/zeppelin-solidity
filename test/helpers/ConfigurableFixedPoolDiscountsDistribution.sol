import '../../contracts/crowdsale/FixedPoolWithDiscountsTokenDistributionStrategy.sol';

contract ConfigurableFixedPoolDiscountsDistribution is FixedPoolWithDiscountsTokenDistributionStrategy {

  event IntervalCount(uint256 count);

  function ConfigurableFixedPoolDiscountsDistribution(ERC20 _token)
    FixedPoolWithDiscountsTokenDistributionStrategy(_token) {

  }

  function addInterval(uint256 _end, uint256 _discount) {
    contributionIntervals.push(DiscountInterval(_end,_discount));
  }

  //@dev this is made to fail the test because we didnt set a period
  function initIntervals() internal {
    //Do something so this is not an abstract contract
    IntervalCount(contributionIntervals.length);
  }

}
