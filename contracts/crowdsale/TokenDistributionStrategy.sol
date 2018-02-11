pragma solidity ^0.4.18;

import '../token/ERC20/ERC20.sol';
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

  function TokenDistributionStrategy(uint256 _rate) public {
    require(_rate > 0);
    rate = _rate;
  }

  /**
  * @title initializeDistribution
  * @dev initialize tokenDistribution by setting crowdsale contract address
  */
  function initializeDistribution(CompositeCrowdsale _crowdsale) public {
    require(crowdsale == address(0));
    require(_crowdsale != address(0));
    crowdsale = _crowdsale;
  }

  /**
  * @title isContributorAccepted
  * @dev extensive method to be used before purchasing, for example whitelisted crowdsale
  */
  function isContributorAccepted(address beneficiary) view public returns (bool accepted){
    return true;
  }

  /**
  * @title distributeTokens
  * @dev extensive method to be used in token purchasing, distribute tokens for user according the 
  *      conditions(discounts, bonus, etc)
  */
  function distributeTokens(address beneficiary, uint amount) public onlyCrowdsale {}

  /**
  * @title calculateTokenAmount
  * @dev extensive method to be used to calculate token amount acordding to user eth purchase
  */
  function calculateTokenAmount(uint256 weiAmount, address beneficiary) view public returns (uint256 amount);

  /**
  * @title getToken
  * @dev get selling token instance
  */
  function getToken() view public returns(ERC20);
}
