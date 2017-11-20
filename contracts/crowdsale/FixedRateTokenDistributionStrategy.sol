pragma solidity ^0.4.11;

import '../token/MintableToken.sol';
import './TokenDistributionStrategy.sol';
import '../token/ERC20.sol';

/**
 * @title FixedRateTokenDistributionStrategy
 * @dev Strategy that grants a fixed number of tokens per donation value
 * Final number of tokens is not defined as it depends on the total amount
 * of contributions that are collected during the crowdsale.
 */
contract FixedRateTokenDistributionStrategy is TokenDistributionStrategy {

  // The token being sold
  MintableToken token;

  function FixedRateTokenDistributionStrategy(uint256 _rate) TokenDistributionStrategy(_rate){

  }

  function initializeDistribution(CompositeCrowdsale _crowdsale) {
    super.initializeDistribution(_crowdsale);
    token = new MintableToken();
  }

  function distributeTokens(address beneficiary, uint amount) onlyCrowdsale {
    token.mint(beneficiary, amount);
  }

  function getToken() constant returns(ERC20) {
    return token;
  }

  function calculateTokenAmount(uint256 weiAmount) constant returns (uint256 amount) {
    return weiAmount.mul(rate);
  }

}
