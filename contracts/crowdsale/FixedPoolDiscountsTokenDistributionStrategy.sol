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
contract FixedPoolDiscountsTokenDistributionStrategy is TokenDistributionStrategy {
  using SafeMath for uint256;

  // Definition of the interval when the discount is applicable
  DiscountInterval[] intervals;
  struct DiscountInterval {
    //end timestamp
    uint256 endTime;
    // percentage
    uint256 discount;
  }

  // The token being sold
  ERC20 token;
  mapping(address => uint256) contributions;
  uint256 totalContributed;
  //mapping(uint256 => DiscountInterval) intervals;

  function FixedPoolDiscountsTokenDistributionStrategy(ERC20 _token) {
    token = _token;
  }

  function calculateTokenAmount(uint256 _weiAmount, uint256 _rate) constant returns (uint256 tokens) {
    // calculate discount in function of the time
    uint startTime = crowdsale.startTime();
    intervals.push(DiscountInterval(startTime + 1 weeks,30));
    intervals.push(DiscountInterval(startTime + 3 weeks,20));
    intervals.push(DiscountInterval(startTime + 5 weeks,10));
    for (uint i = 0; i < intervals.length; i++) {
      if (now <= intervals[i].endTime) {
        // calculate token amount to be created
        tokens = _weiAmount.mul(_rate);
        // OP : tokens + (tokens * intervals[i].discount / 100)
        uint256 discount = intervals[i].discount;
        return tokens.add(tokens.mul(discount.div(100)));
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
}
