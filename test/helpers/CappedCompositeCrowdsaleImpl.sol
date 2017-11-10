pragma solidity ^0.4.11;


import '../../contracts/crowdsale/CappedCompositeCrowdsale.sol';


contract CappedCompositeCrowdsaleImpl is CappedCompositeCrowdsale {

  function CappedCompositeCrowdsaleImpl (
    uint256 _startTime,
    uint256 _endTime,
    uint256 _rate,
    address _wallet,
    uint256 _cap
  )
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    CappedCompositeCrowdsale(_cap)
  {
  }

}
