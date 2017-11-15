import '../../contracts/crowdsale/FixedPoolWithDiscountsTokenDistributionStrategy.sol';

contract EmptyIntervalsDistribution is FixedPoolWithDiscountsTokenDistributionStrategy {


  function EmptyIntervalsDistribution(ERC20 _token)
    FixedPoolWithDiscountsTokenDistributionStrategy(_token) {

  }

  //@dev this is made to fail the test because we didnt set a period
  function initIntervals() internal validateIntervals {
    //Do something so this is not an abstract contract
    uint justSoIsNotAbstract = 0;

  }

}
