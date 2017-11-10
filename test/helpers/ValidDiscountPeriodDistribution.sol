pragma solidity ^0.4.11;

import '../../contracts/crowdsale/FixedPoolWithDiscountsTokenDistributionStrategy.sol'

contract ValidDiscountPeriodDistribution is FixedPoolWithDiscountsTokenDistributionStrategy {

  function ValidDiscountPeriodDistribution(ERC20 _token)
    FixedPoolWithDiscountsTokenDistributionStrategy(_token) {

  }

  function initIntervals() validateIntervals {
    uint256 startTime = crowdsale.startTime();
    contributionIntervals = [
      DiscountInterval(startTime + 2 days, 1.3),
      DiscountInterval(startTime + 4 days, 1.3)
    ];
  }

}
