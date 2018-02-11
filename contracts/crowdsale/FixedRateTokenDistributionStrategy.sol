pragma solidity ^0.4.18;

import '../token/ERC20/MintableToken.sol';
import './TokenDistributionStrategy.sol';
import '../token/ERC20/ERC20.sol';

/**
 * @title FixedRateTokenDistributionStrategy
 * @dev Strategy that grants a fixed number of tokens per donation value
 * Final number of tokens is not defined as it depends on the total amount
 * of contributions that are collected during the crowdsale.
 */
contract FixedRateTokenDistributionStrategy is TokenDistributionStrategy {

  // The token being sold
  MintableToken token;

  function FixedRateTokenDistributionStrategy(uint256 _rate) TokenDistributionStrategy(_rate) public {

  }

  /**
  * @title initializeDistribution
  * @dev initialize tokenDistribution by setting crowdsale contract address
  */
  function initializeDistribution(CompositeCrowdsale _crowdsale) public {
    super.initializeDistribution(_crowdsale);
    token = new MintableToken();
  }

  /**
  * @title distributeTokens
  * @dev extensive method to be used in token purchasing, distribute tokens for user according the 
  *      conditions(discounts, bonus, etc)
  */
  function distributeTokens(address beneficiary, uint amount) public onlyCrowdsale {
    token.mint(beneficiary, amount);
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
  */
  function calculateTokenAmount(uint256 weiAmount, address beneficiary) view public returns (uint256 amount) {
    return weiAmount.mul(rate);
  }

}
