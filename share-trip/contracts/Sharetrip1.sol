pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract Sharetrip1 is Ownable {
  enum TripStatus { Unstarted, Started, Finished }
  TripStatus public status;
  
  mapping(address => uint) public balances;
  uint256 public minAmountToJoin;
  address[] public pendingMembers;
  address[] public members;
  uint256 public pendingMembersCount;
  uint256 public totalMemberBalance;

  event JoinRequest(address indexed from, uint256 value);
  event JoinRequestAccepted(address indexed from);
  event JoinRequestRejected(address indexed from);
  event JoinDepositWithdrawn(address indexed from, uint256 value);
  event TripStarted(uint256 totalMembers, uint256 totalFunds);

  function Sharetrip1(
    uint256 minAmount
  ) payable {
    // Keep minAmountToJoin greater than 0 to avoid problem mentioned in joinTrip
    require(msg.value >= (minAmount * 1 finney));
    status = TripStatus.Unstarted;
    minAmountToJoin = minAmount;
    members.push(msg.sender);
    balances[msg.sender] = msg.value;
  }

  function joinTrip() payable {
    require(status == TripStatus.Unstarted);
    require(msg.value >= (minAmountToJoin * 1 finney));
    require(balances[msg.sender] == 0);  // cant join twice from same address, assuming minAmountToJoin > 0
    pendingMembers.push(msg.sender);
    balances[msg.sender] = msg.value;
    pendingMembersCount++;
    JoinRequest(msg.sender, msg.value);
  }

  function acceptJoinRequest(address from) onlyOwner {
    require(status == TripStatus.Unstarted);
    if (markRemoved(from)) {
      members.push(from);
      pendingMembersCount--;
      JoinRequestAccepted(from);
    }
  }

  function rejectJoinRequest(address from) onlyOwner {
    require(status == TripStatus.Unstarted);
    if (removePending(from)) {
      JoinRequestRejected(from);
    }
  }

  function startTrip() onlyOwner {
    status = TripStatus.Started;
    totalMemberBalance = getTotalBalance();
    TripStarted(members.length, totalMemberBalance);
  }

  function withdrawJoinDeposit(address from) returns (bool) {
    require(msg.sender == from);
    if (balances[from] > 0 && !isPending(from) && !isMember(from)) {
      // Only if `from` is not a member and not pending (request was rejected) and has >0 balance 
      uint256 bal = balances[from];
      balances[from] = 0;
      if (msg.sender.send(bal)) {     // Send deposited ether back to the requester
        JoinDepositWithdrawn(from, bal);
        return true;
      } else {
        balances[from] = bal;
      }
    }
    return false;
  }

  function removePending(address from) internal returns (bool) {
    if (markRemoved(from)) {
      pendingMembersCount--;
      return true;
    }
    return false;
  }

  function markRemoved(address pending) internal returns (bool) {
    for (uint i = 0; i < pendingMembers.length; i++) {
      if (pendingMembers[i] == address(0)) {   // removed address
        continue;
      }
      if (pendingMembers[i] == pending) {
        pendingMembers[i] = address(0);    // mark removed
        return true;
      }
    }
    return false;
  }

  function getTotalBalance() constant returns (uint256) {
    uint256 sum = 0;
    for (uint i = 0; i < members.length; i++) {
      sum += balances[members[i]];
    }
    return sum;
  }

  function isPending(address requester) constant returns (bool) {
    for (uint i = 0; i < pendingMembers.length; i++) {
      if (pendingMembers[i] == requester) {
        return true;
      }
    }
    return false;
  }

  function isMember(address requester) constant returns (bool) {
    for (uint i = 0; i < members.length; i++) {
      if (members[i] == requester) {
        return true;
      }
    }
    return false;
  }

  function getMemberCount() constant returns (uint) {
    return members.length;
  }
}
