pragma solidity ^0.4.18;

import './TokenDistributionStrategy.sol';
import '../token/ERC20/ERC20.sol';
import '../math/SafeMath.sol';

/**
 * @title FixedRateTokenDistributionStrategy
 * @dev Strategy that distributes a fixed number of tokens among the contributors.
 * It's done in two steps. First, it registers all of the contributions while the sale is active.
 * After the crowdsale has ended the contract compensate buyers proportionally to their contributions.
 */
contract FixedPoolTokenDistributionStrategy is TokenDistributionStrategy {

  // The token being sold
  ERC20 token;
  mapping(address => uint256) contributions;
  uint256 totalContributed;
 
  function FixedPoolTokenDistributionStrategy(ERC20 _token, uint256 _rate)
    TokenDistributionStrategy(_rate) public{
    token = _token;
  }

  /**
  * @title distributeTokens
  * @dev extensive method to be used in token purchasing, distribute tokens for user according the 
  *      conditions(discounts, bonus, etc)
  */
  function distributeTokens(address _beneficiary, uint256 _amount) public onlyCrowdsale {
    contributions[_beneficiary] = contributions[_beneficiary].add(_amount);
    totalContributed = totalContributed.add(_amount);
  }

  /**
  * @title compensate
  * @dev send token to user
  */
  function compensate(address _beneficiary) public {
    require(crowdsale.hasEnded());
    uint256 amount = contributions[_beneficiary].mul(token.totalSupply()).div(totalContributed);
    if (token.transfer(_beneficiary, amount)) {
      contributions[_beneficiary] = 0;
    }
  }

  /**
  * @title getToken
  * @dev get selling token instance
  */
  function getToken() view public returns(ERC20) {
    return token;
  }

  /**
  * @title calculateTokenAmount
  * @dev extensive method to be used to calculate token amount acordding to user eth purchase
  * calcualte token amount according to the discount period at that moment
  */
  function calculateTokenAmount(uint256 weiAmount, address beneficiary) view public returns (uint256 amount) {
    return weiAmount.mul(rate);
  }
}
