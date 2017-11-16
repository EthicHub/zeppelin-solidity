pragma solidity ^0.4.11;

import './TokenDistributionStrategy.sol';
import '../token/ERC20.sol';
import '../math/SafeMath.sol';

/**
 * @title FixedPoolWithDiscountsTokenDistributionStrategy
 * @dev Strategy that distributes a fixed number of tokens among the contributors,
 * with a percentage deppending in when the contribution is made, defined by periods.
 * It's done in two steps. First, it registers all of the contributions while the sale is active.
 * After the crowdsale has ended the contract compensate buyers proportionally to their contributions.
 * This class is abstract, the intervals have to be defined by subclassing
 */
contract FixedPoolWithDiscountsTokenDistributionStrategy is TokenDistributionStrategy {
  // The token being sold
  ERC20 token;

  // Definition of the interval when the discount is applicable
  struct DiscountInterval {
    //end timestamp
    uint256 end;
    // percentage
    uint discount;
  }
  mapping(address => uint256) contributions;

  uint256 totalContributed;
  DiscountInterval[] contributionIntervals;

  event Log(uint256 message);

  function FixedPoolWithDiscountsTokenDistributionStrategy(ERC20 _token) {
    token = _token;
  }

  //TODO add this to initIntervals()
  // First period will go from crowdsale.start_date to contributionIntervals[0].end
  // Next intervals have to end after the previous ones
  // Last interval must end when the crowdsale ends
  // All intervals must have a positive discount (penalizations are not contemplated)
  modifier validateIntervals {
    _;
    require(contributionIntervals.length > 0);
    for(uint i = 0; i < contributionIntervals.length; ++i) {
      require(contributionIntervals[i].discount > 0);
      if (i == 0) {
        require(crowdsale.startTime() < contributionIntervals[i].end);
      } else {
        require(contributionIntervals[i-1].end < contributionIntervals[i].end);
        require(contributionIntervals[i].end <= crowdsale.endTime());
      }
    }
  }

  //@dev override to define the intervals
  function initIntervals() internal {}

  //@dev overriding to init the time intervals according to crodsale dates
  function initializeDistribution(CompositeCrowdsale _crowdsale) {
    super.initializeDistribution(_crowdsale);
    initIntervals();
  }

  function distributeTokens(address _beneficiary, uint256 _amount) onlyCrowdsale {
    contributions[_beneficiary] = contributions[_beneficiary].add(_amount);
    totalContributed = totalContributed.add(_amount);
  }

  function compensate(address _beneficiary) {
    //FIXME remove this
    uint notAbstractJustForTest = 0;
  }

  function getToken() constant returns(ERC20) {
    return token;
  }

  function getIntervals() constant returns (uint256[] _ends, uint[] _discount) {
    uint256[] memory ends = new uint256[](contributionIntervals.length);
    uint[] memory discounts = new uint[](contributionIntervals.length);
    for (uint256 i=0; i<contributionIntervals.length; i++) {
      ends[i] = contributionIntervals[i].end;
      discounts[i] = contributionIntervals[i].discount;
    }
    return (ends, discounts);
  }

  function getCrowdsale() constant returns(CompositeCrowdsale) {
    return crowdsale;
  }

  function calculateTokenAmount(uint weiAmount,uint rate) constant returns(uint256 tokens) {
    return weiAmount.mul(rate);
  }
}
