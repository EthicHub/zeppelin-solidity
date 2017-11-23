pragma solidity ^0.4.11;

import '../examples/SimpleToken.sol';
import './TokenDistributionStrategy.sol';
import '../token/ERC20.sol';
import '../math/SafeMath.sol';

/**
 * @title FixedRateTokenDistributionStrategy
 * @dev Strategy that distributes a fixed number of tokens among the contributors,
 * with a percentage deppending in when the contribution is made, defined by periods.
 * It's done in two steps. First, it registers all of the contributions while the sale is active.
 * After the crowdsale has ended the contract compensate buyers proportionally to their contributions.
 * This class is abstract, the intervals have to be defined by subclassing
 */
contract FixedPoolWithDiscountsTokenDistributionStrategy is TokenDistributionStrategy {
  using SafeMath for uint256;
  //event Log
  event Log(uint256 message);
  event LogString(string message);

  // Definition of the interval when the discount is applicable
  struct DiscountInterval {
    //end timestamp
    uint256 endPeriod;
    // percentage
    uint256 discount;
  }
  DiscountInterval[] discountIntervals;

  // The token being sold
  ERC20 token;
  mapping(address => uint256) contributions;
  uint256 totalContributed;
  //mapping(uint256 => DiscountInterval) discountIntervals;

  function FixedPoolWithDiscountsTokenDistributionStrategy(ERC20 _token) {
    token = _token;
  }

  // First period will go from crowdsale.start_date to discountIntervals[0].end
  // Next intervals have to end after the previous ones
  // Last interval must end when the crowdsale ends
  // All intervals must have a positive discount (penalizations are not contemplated)
  modifier validateIntervals {
    _;
    require(discountIntervals.length > 0);
    for(uint i = 0; i < discountIntervals.length; ++i) {
      require(discountIntervals[i].discount > 0);
      if (i == 0) {
        require(crowdsale.startTime() < discountIntervals[i].endPeriod);
      } else {
        require(discountIntervals[i-1].endPeriod < discountIntervals[i].endPeriod);
        require(discountIntervals[i].endPeriod <= crowdsale.endTime());
      }
    }
  }

  // Init intervals
  function initIntervals() validateIntervals {
    //require (discountIntervals.length == 0);
    //uint256 startTime = crowdsale.startTime();
    //discountIntervals.push(DiscountInterval(startTime + 1 weeks,30));
    //discountIntervals.push(DiscountInterval(startTime + 3 weeks,20));
    //discountIntervals.push(DiscountInterval(startTime + 5 weeks,10));
  }

  function calculateTokenAmount(uint256 _weiAmount, uint256 _rate) constant returns (uint256 tokens) {
    // calculate discount in function of the time
    for (uint i = 0; i < discountIntervals.length; i++) {
      if (now <= discountIntervals[i].endPeriod) {
        // calculate token amount to be created
        tokens = _weiAmount.mul(_rate);
        // OP : tokens + ((tokens * discountIntervals[i].discount) / 100)
        // BE CAREFULLY with decimals
        return tokens.add(tokens.mul(discountIntervals[i].discount).div(100));
      }
    }
  }

  function distributeTokens(address _beneficiary, uint256 _tokenAmount) onlyCrowdsale {
    contributions[_beneficiary] = contributions[_beneficiary].add(_tokenAmount);
    totalContributed = totalContributed.add(_tokenAmount);
  }

  function compensate(address _beneficiary) {
    require(crowdsale.hasEnded());
    uint256 amount = contributions[_beneficiary].mul(token.totalSupply()).div(totalContributed);
    if (token.transfer(_beneficiary, amount)) {
      contributions[_beneficiary] = 0;
    }
  }

  function getToken() constant returns(ERC20) {
    return token;
  }

  function getIntervals() constant returns (uint256[] _endPeriods, uint256[] _discounts) {
    uint256[] memory endPeriods = new uint256[](discountIntervals.length);
    uint256[] memory discounts = new uint256[](discountIntervals.length);
    for (uint256 i=0; i<discountIntervals.length; i++) {
      endPeriods[i] = discountIntervals[i].endPeriod;
      discounts[i] = discountIntervals[i].discount;
    }
    return (endPeriods, discounts);
  }

}
