pragma solidity ^0.4.18;

import '../token/ERC20.sol';
import './CompositeCrowdsale.sol';
import '../math/SafeMath.sol';

/**
 * @title TokenDistributionStrategy
 * @dev Base abstract contract defining methods that control token distribution
 */
contract TokenDistributionStrategy {
  using SafeMath for uint256;

  CompositeCrowdsale crowdsale;
  uint256 rate;

  modifier onlyCrowdsale() {
    require(msg.sender == address(crowdsale));
    _;
  }

  function TokenDistributionStrategy(uint256 _rate) {
    require(_rate > 0);
    rate = _rate;
  }

  function initializeDistribution(CompositeCrowdsale _crowdsale) {
    require(crowdsale == address(0));
    require(_crowdsale != address(0));
    crowdsale = _crowdsale;
  }

  function distributeTokens(address beneficiary, uint amount) onlyCrowdsale {}

  function calculateTokenAmount(uint256 weiAmount) constant returns (uint256 amount);

  function getToken() constant returns(ERC20);


}
