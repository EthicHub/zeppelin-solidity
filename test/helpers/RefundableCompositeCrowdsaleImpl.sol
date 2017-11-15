pragma solidity ^0.4.11;


import '../../contracts/crowdsale/RefundableCompositeCrowdsale.sol';


contract RefundableCompositeCrowdsaleImpl is RefundableCompositeCrowdsale {

  function RefundableCompositeCrowdsaleImpl (
    uint256 _startTime,
    uint256 _endTime,
    uint256 _rate,
    address _wallet,
    TokenDistributionStrategy _tokenDistribution,
    uint256 _goal
  )
    CompositeCrowdsale(_startTime, _endTime, _rate, _wallet, _tokenDistribution)
    RefundableCompositeCrowdsale(_goal)
  {
  }

}
