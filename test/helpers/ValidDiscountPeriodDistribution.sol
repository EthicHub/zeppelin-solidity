pragma solidity ^0.4.11;

import '../../contracts/crowdsale/FixedPoolWithDiscountsTokenDistributionStrategy.sol';

contract ValidDiscountPeriodDistribution is FixedPoolWithDiscountsTokenDistributionStrategy {


  function ValidDiscountPeriodDistribution(ERC20 _token)
    FixedPoolWithDiscountsTokenDistributionStrategy(_token) {

  }
  //@dev set periods for tests
  function initIntervals() internal validateIntervals {
    uint256 startTime = crowdsale.startTime();
    contributionIntervals.push(DiscountInterval(startTime + 2 days, 30));
    //contributionIntervals.push(DiscountInterval(startTime + 4 days, 20));
  }

}
