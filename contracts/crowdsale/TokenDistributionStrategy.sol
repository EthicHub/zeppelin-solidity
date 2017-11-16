pragma solidity ^0.4.11;

import '../token/ERC20.sol';
import './CompositeCrowdsale.sol';
import '../math/SafeMath.sol';

/**
 * @title TokenDistributionStrategy
 * @dev Base abstract contract defining methods that control token distribution
 */
contract TokenDistributionStrategy {

  CompositeCrowdsale crowdsale;
  using SafeMath for uint256;

  modifier onlyCrowdsale() {
    require(msg.sender == address(crowdsale));
    _;
  }

  function initializeDistribution(CompositeCrowdsale _crowdsale) {
    require(crowdsale == address(0));
    require(_crowdsale != address(0));
    crowdsale = _crowdsale;
  }

  function distributeTokens(address beneficiary, uint amount) onlyCrowdsale {}

  function getToken() constant returns(ERC20);

  //TODO rate should be a TokenDistributionStrategy parameter, not a crowdsale one
  function calculateTokenAmount(uint weiAmount,uint rate) constant returns(uint tokens);

}
