pragma solidity ^0.4.11;

import '../../contracts/crowdsale/FixedPoolWithDiscountsTokenDistributionStrategy.sol';

contract ValidDiscountPeriodDistribution is FixedPoolWithDiscountsTokenDistributionStrategy {

  event Test(uint256 message);

  function ValidDiscountPeriodDistribution(ERC20 _token)
    FixedPoolWithDiscountsTokenDistributionStrategy(_token) {

  }
  //@dev set periods for tests
  function initIntervals() internal validateIntervals {
    uint256 startTime = 1510752626;
    Test(startTime);
    contributionIntervals.push(DiscountInterval(startTime + 2 days, 30));
    Test(contributionIntervals.length);

    //contributionIntervals.push(DiscountInterval(startTime + 4 days, 20));
  }

}
