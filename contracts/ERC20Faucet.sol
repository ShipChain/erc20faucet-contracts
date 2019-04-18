// ERC20Faucet
// Copyright (C) 2018  WeTrustPlatform
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.5.6;

import {SafeMath} from "openzeppelin-solidity/contracts/math/SafeMath.sol";
import {IERC20} from "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract ERC20Faucet {
  using SafeMath for uint256;

  uint256 public maxAllowanceInclusive;
  mapping (address => uint256) public claimedTokens;
  IERC20 public erc20Contract;
  bool public isPaused = false;

  address private mOwner;
  bool private mReentrancyLock = false;

  event GetTokens(address requestor, uint256 amount);
  event ReclaimTokens(address owner, uint256 tokenAmount);
  event SetPause(address setter, bool newState, bool oldState);
  event SetMaxAllowance(address setter, uint256 newState, uint256 oldState);

  modifier notPaused() {
    require(!isPaused);
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == mOwner);
    _;
  }

  modifier nonReentrant() {
    require(!mReentrancyLock);
    mReentrancyLock = true;
    _;
    mReentrancyLock = false;
  }

  constructor(IERC20 _erc20ContractAddress, uint256 _maxAllowanceInclusive) public {
    mOwner = msg.sender;
    maxAllowanceInclusive = _maxAllowanceInclusive;
    erc20Contract = _erc20ContractAddress;
  }

  function getTokens(uint256 amount) notPaused nonReentrant public returns (bool) {
    require(claimedTokens[msg.sender].add(amount) <= maxAllowanceInclusive);
    require(erc20Contract.balanceOf(address(this)) >= amount);
    
    claimedTokens[msg.sender] = claimedTokens[msg.sender].add(amount);

    if (!erc20Contract.transfer(msg.sender, amount)) {
      claimedTokens[msg.sender] = claimedTokens[msg.sender].sub(amount);
      return false;
    }
    
    emit GetTokens(msg.sender, amount);
    return true;
  }

  function setMaxAllowance(uint256 _maxAllowanceInclusive) onlyOwner nonReentrant public {
    emit SetMaxAllowance(msg.sender, _maxAllowanceInclusive, maxAllowanceInclusive);
    maxAllowanceInclusive = _maxAllowanceInclusive;
  }

  function reclaimTokens() onlyOwner nonReentrant public returns (bool) {
    uint256 tokenBalance = erc20Contract.balanceOf(address(this));
    if (!erc20Contract.transfer(msg.sender, tokenBalance)) {
      return false;
    }

    emit ReclaimTokens(msg.sender, tokenBalance);
    return true;
  }

  function setPause(bool _isPaused) onlyOwner nonReentrant public {
    emit SetPause(msg.sender, _isPaused, isPaused);
    isPaused = _isPaused;
  }
}
