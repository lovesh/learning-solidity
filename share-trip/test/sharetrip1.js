var Web3 = require("../node_modules/web3/");
web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
var Sharetrip1 = artifacts.require("./Sharetrip1.sol");

contract('Sharetrip1', function (accounts) {
  var trip;

  function doActionsInOrder(allActions) {
    return allActions.reduce((acc, p) => acc.then(function () { return p[0].apply(null, p[1]); }), Promise.resolve());
  }

  function successLogger(tx) {
    console.log(tx);
    console.log("success here ^^^^^^");
  }

  function errorLogger(error) {
    console.log(error);
    console.log("error here ^^^^^");
  }

  function checkMemberCount(expectedCount) {
    return trip.getMemberCount.call().then(function (mc) {
      assert.equal(mc.valueOf(), expectedCount, "member count was not " + expectedCount);
    });
  }

  function checkPendingCount(expectedCount) {
    return trip.pendingMembersCount.call().then(function (pc) {
      assert.equal(pc.valueOf(), expectedCount, "pending count was not " + expectedCount);
    });
  }

  function checkBalance(address, expectedFinney) {
    return trip.balances.call(address).then(function (balance) {
      assert.equal(web3.fromWei(balance.valueOf(), 'finney'), expectedFinney, expectedFinney + " wasn't in the first account");
    });
  }

  function checkMember(address) {
    return trip.isMember.call(address).then(function (m) {
      assert.equal(m, true, address + " not member");
    });
  }

  function checkPending(address) {
    return trip.isPending.call(address).then(function (p) {
      assert.equal(p, true, address + " not pending");
    });
  }

  function sendJoinReq(address, minFinney) {
    console.log('Join request being sent by ' + address);
    return trip.joinTrip({ from: address, to: trip.address, value: web3.toWei(minFinney, "finney") })
      .then(successLogger, errorLogger);
  }

  function acceptJoinReq(sender, requestee) {
    console.log('Join request being accepted by ' + sender + ' for ' + requestee);
    return trip.acceptJoinRequest(requestee, { from: sender })
      .then(successLogger, errorLogger);
  }

  function rejectJoinReq(sender, requestee) {
    console.log('Join request being rejected by ' + sender + ' for ' + requestee);
    return trip.rejectJoinRequest(requestee, { from: sender })
      .then(successLogger, errorLogger);
  }

  function withdrawJoinDep(sender, requestee) {
    console.log('Withdrawl attempt from ' + sender + ' for ' + requestee);
    return trip.withdrawJoinDeposit(requestee, { from: sender })
      .then(successLogger, errorLogger);
  }

  function startTrip(sender) {
    return trip.startTrip({ from: sender })
      .then(successLogger, errorLogger);
  }

  function checkTripStatus(expectedStatus) {
    return trip.status.call().then(function (s) {
      assert.equal(s.valueOf(), expectedStatus, "status was not " + expectedStatus);
    });
  }

  before(function () {
    return Sharetrip1.new(10, { from: web3.eth.accounts[0], value: 10000000000000000000, gas: 2100000 })
      .then(function (instance) {
        // Get a reference to the deployed trip contract, as a JS object.
        trip = instance;
      });
  });

  it("should put at 10000 finney in the first account", function () {
    // The owner deposited 1000 finney, it should have those in balance
    return checkBalance(accounts[0], 10000);
  });

  it("should have only 1 member", function () {
    // The owner deposited 1000 finney, it should have those in balance
    return checkMemberCount(1);
  });

  it("should let people send join request only if people send ether above minimum amount", function () {
    var allActions = [
      [checkPendingCount, [0]],
      [sendJoinReq, [accounts[1], 1]],
      [checkPendingCount, [0]],
      [sendJoinReq, [accounts[1], 100]],
      [checkPendingCount, [1]],
      [checkPending, [accounts[1]]],
      [checkMemberCount, [1]],
    ];
    // return allActions.reduce((acc, p) => acc.then(p[0].apply(null, p[1])), Promise.resolve());
    return doActionsInOrder(allActions);
  });

  it("owner should let the owner accept the join request", function () {
    /*checkMemberCount(1);
    checkPendingCount(1);

    // non owner accepts join request
    acceptJoinReq(accounts[1], accounts[1]);
    checkMemberCount(1);
    checkPendingCount(1);

    // owner accepts join request
    acceptJoinReq(accounts[0], accounts[1]);
    checkPendingCount(0);
    checkMember(accounts[1]);
    return checkMemberCount(2);*/
    var allActions = [
      [checkMemberCount, [1]],
      [checkPendingCount, [1]],
      // non owner accepts join request
      [acceptJoinReq, [accounts[1], accounts[1]]],
      [checkMemberCount, [1]],
      [checkPendingCount, [1]],
      // owner accepts join request
      [acceptJoinReq, [accounts[0], accounts[1]]],
      [checkPendingCount, [0]],
      [checkMember, [accounts[1]]],
      [checkMemberCount, [2]],
    ];
    return doActionsInOrder(allActions);
  });

  it("should let the owner reject the join request", function () {
    /*checkMemberCount(2);
    checkPendingCount(0);

    sendJoinReq(accounts[2], 100);
    checkPendingCount(1);

    // non owner cannot reject join request
    rejectJoinReq(accounts[1], accounts[2]);
    checkPendingCount(1);

    // owner rejects join request
    rejectJoinReq(accounts[0], accounts[2]);
    checkPendingCount(0);

    return checkMemberCount(2);*/
    var allActions = [
      [checkMemberCount, [2]],
      [checkPendingCount, [0]],
      [sendJoinReq, [accounts[2], 100]],
      [checkPendingCount, [1]],
      // non owner cannot reject join request
      [rejectJoinReq, [accounts[1], accounts[2]]],
      [checkPendingCount, [1]],

      // owner rejects join request
      [rejectJoinReq, [accounts[0], accounts[2]]],
      [checkPendingCount, [0]],
      [checkMemberCount, [2]],
    ];
    return doActionsInOrder(allActions);
  });

  it("should let a requestee withdraw his amount only after the trip owner rejected his request", function () {
    // Trip owner cannot withdraw amount
    /*checkBalance(accounts[2], 100);
    withdrawJoinDep(accounts[0], accounts[2]);
    checkBalance(accounts[2], 100);
    // Amount owner can withdraw amount
    ethBalBefore = web3.eth.getBalance(accounts[2]).valueOf();
    withdrawJoinDep(accounts[2], accounts[2]);
    checkBalance(accounts[2], 0);
    ethBalAfter = web3.eth.getBalance(accounts[2]).valueOf();
    // assert.isAbove(ethBalAfter, ethBalBefore, ethBalAfter + ' is not greater than ' + ethBalBefore);
  
    // Cannot withdraw before request rejected by trip owner
    sendJoinReq(accounts[3], 100);
    checkPendingCount(1);
    withdrawJoinDep(accounts[3], accounts[3]);
    checkBalance(accounts[3], 100);
  
    rejectJoinReq(accounts[0], accounts[3]);
    checkPendingCount(0);
    withdrawJoinDep(accounts[3], accounts[3]);
    return checkBalance(accounts[3], 0);*/
    console.log(6, new Date());
    /*return checkBalance(accounts[2], 100).then(function () {
      // Trip owner cannot withdraw amount
      console.log(61, new Date());
      withdrawJoinDep(accounts[0], accounts[2]).then(function () {
        console.log(62, new Date());
        checkBalance(accounts[2], 100).then(function () {
          console.log(63, new Date());
          ethBalBefore = web3.eth.getBalance(accounts[2]).valueOf();
          // Amount owner can withdraw amount
          withdrawJoinDep(accounts[2], accounts[2]).then(function () {
            checkBalance(accounts[2], 0).then(function () {
              ethBalAfter = web3.eth.getBalance(accounts[2]).valueOf();
              // Ether balance increases after withdrawn trip join amount
              assert.isAbove(ethBalAfter, ethBalBefore, ethBalAfter + ' is not greater than ' + ethBalBefore);
              console.log('Balance increased from ' + ethBalBefore + ' to ' + ethBalAfter);
              // Cannot withdraw before request rejected by trip owner
              sendJoinReq(accounts[3], 100).then(function () {
                checkPendingCount(1).then(function () {
                  withdrawJoinDep(accounts[3], accounts[3]).then(function () {
                    checkBalance(accounts[3], 100).then(function () {
                      rejectJoinReq(accounts[0], accounts[3]).then(function () {
                        checkPendingCount(0).then(function () {
                          withdrawJoinDep(accounts[3], accounts[3]).then(function () {
                            checkBalance(accounts[3], 0)
                          })
                        })
                      })
                    })
                  })
                })
              });
            });
          })
        })
      })
    });*/

    return checkBalance(accounts[2], 100)
      .then(function () {
        console.log(61, new Date());
        return withdrawJoinDep(accounts[0], accounts[2]);
      })
      .then(function () {
        console.log(62, new Date());
        return checkBalance(accounts[2], 100);
      })
      .then(function () {
        console.log(63, new Date());
        ethBalBefore = web3.eth.getBalance(accounts[2]).valueOf();
        // Amount owner can withdraw amount
        return withdrawJoinDep(accounts[2], accounts[2]);
      })
      .then(function () {
        return checkBalance(accounts[2], 0);
      })
      .then(function () {
        ethBalAfter = web3.eth.getBalance(accounts[2]).valueOf();
        // Ether balance increases after withdrawn trip join amount
        assert.isAbove(ethBalAfter, ethBalBefore, ethBalAfter + ' is not greater than ' + ethBalBefore);
        console.log('Balance increased from ' + ethBalBefore + ' to ' + ethBalAfter);
        // Cannot withdraw before request rejected by trip owner
        return sendJoinReq(accounts[3], 100);
      })
      .then(function () {
        return checkPendingCount(1);
      })
      .then(function () {
        return withdrawJoinDep(accounts[3], accounts[3]);
      })
      .then(function () {
        return checkBalance(accounts[3], 100);
      })
      .then(function () {
        return rejectJoinReq(accounts[0], accounts[3]);
      })
      .then(function () {
        return checkPendingCount(0);
      })
      .then(function () {
        return withdrawJoinDep(accounts[3], accounts[3]);
      })
      .then(function () {
        return checkBalance(accounts[3], 0);
      });
  });

  it("should not let a member (requestee who was accepted by trip owner) withdraw his amount", function () {
    console.log(7, new Date());
    var ethBalBefore, ethBalAfter;
    var allActions = [
      [sendJoinReq, [accounts[4], 100]],
      [checkPendingCount, [1]],
      [checkMemberCount, [2]],
      [checkPending, [accounts[4]]],

      // owner accepts join request
      [acceptJoinReq, [accounts[0], accounts[4]]],
      [checkMemberCount, [3]],
      [checkMember, [accounts[4]]],
      [checkPendingCount, [0]],

      [withdrawJoinDep, [accounts[4], accounts[4]]],
      [checkBalance, [accounts[4], 100]],
    ];

    return doActionsInOrder(allActions);

  });

  it("should not let anyone send a join request for trip nor let the owner accept a join request after trip starts", function () {
    console.log(8, new Date());
    var allActions = [
      [sendJoinReq, [accounts[5], 100]],
      [checkPendingCount, [1]],
      [checkMemberCount, [3]],
      [checkPending, [accounts[5]]],

      [checkTripStatus, [0]],
      [startTrip, [accounts[1]]],
      [checkTripStatus, [0]],

      [startTrip, [accounts[0]]],
      [checkTripStatus, [1]],

      [acceptJoinReq, [accounts[0], accounts[5]]],
      [checkPendingCount, [1]],
      [checkPending, [accounts[5]]],

      [sendJoinReq, [accounts[6], 100]],
      [checkPendingCount, [1]],
    ];

    return doActionsInOrder(allActions);
  });

});