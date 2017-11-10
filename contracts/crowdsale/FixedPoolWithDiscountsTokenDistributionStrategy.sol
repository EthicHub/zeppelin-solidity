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
  using SafeMath for uint256;

  // The token being sold
  ERC20 token;

  // Definition of the interval when the discount is applicable
  struct DiscountInterval {
    //end timestamp
    uint256 end;
    // percentage
    uint discount;
    //contributions in this interval
    mapping(address => uint256) contributions;
  }

  DiscountInterval[] contributionIntervals;

  function FixedPoolWithDiscountsTokenDistributionStrategy(ERC20 _token) {
    initIntervals();
    token = _token;
  }

  // First period will go from crowdsale.start_date to contributionIntervals[0].end
  // Next intervals have to end after the previous ones
  // Last interval must end when the crowdsale ends
  // All intervals must have a positive discount (penalizations are not contemplated)
  modifier validateIntervals {
    _;
    assert(contributionIntervals.length > 0);
    for(uint i = 0; i < contributionIntervals.length; ++i) {
      DiscountInterval interval = contributionIntervals[i];
      assert(interval.discount > 0);
      if (i == 0) {
        assert(crowdsale.startTime() < interval.end);
      } if (i == contributionIntervals.length) {
        assert(crowdsale.endTime() == interval.end);
      } else {
        assert(contributionIntervals[i-1].end < interval.end);
      }
    }
  }

  //@dev override to define the intervals
  function initIntervals() internal validateIntervals {

  }

  function distributeTokens(address _beneficiary, uint256 _amount) onlyCrowdsale {

  }

  function compensate(address _beneficiary) {

  }

  function getToken() constant returns(ERC20) {
    return token;
  }
}
