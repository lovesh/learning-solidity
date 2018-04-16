var Web3 = require("../node_modules/web3/");
web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
var Verifier = require("../contracts/Verifier.sol");

contract('Verifier', function (accounts) {
  
  var verifier;

  before(function () {
    return Verifier.new({ from: web3.eth.accounts[0], value: 10000000000000000000, gas: 2100000 })
      .then(function (instance) {
        verifier = instance;
      });
  });

  function checkReturnVal(proof, input) {
    var a = proof.a;
    var a_p = proof.a_p;
    var b = proof.b;
    var b_p = proof.b_p;
    var c = proof.c;
    var c_p = proof.c_p;
    var h = proof.h;
    var k = proof.k;

    return verifier.verifyTx.call(a, a_p, b, b_p, c, c_p, h, k, input).then(function (val) {
      assert.equal(val, true, val + " should be true");
    });
  }

  it("should pass for correct proof and inputs", function () {
    var proof = {
      A: [0x27b8e67b488646d0c82c270c870be0bce8b76244c6ca919e7cb2cc6ff19b6742, 0x234b0c7ebed52c7d4526284817fcc4714c8fa3dfc309ebe0a0b81492128a048c],
      A_p: [0x1fe093b24f5a774b1f79c6e314ebfc0193087df73fdea774a14d6b5a8be9e80d, 0x59b48975871ba7a8e229a2b551a1c7bfc580962af14d3979b35ec4b6f88cbef],
      B: [[0x30ac895bab339a808ca52bad3d4c3b1391c9d501b404ece4f04b390b54bbe6d, 0x2b8866625ad21dbfb4174ae8e4512c50758f4d68e2b5f91e8692bfd2731f7bf6], [0x1542f9bd3d28a0fe46cf43e3b425f4284062305e14321ded9434c2e46a98363a, 0x1e537b71f2683842ee82e9604249a3c5e85943d510e72a2548140f556c446e5f]],
      B_p: [0x2e8d210b0f703ddf941596c682604f3453c752662ffb08698314c35709ece16b, 0x1537f1af45ea762f510706fef798e6cf4edf66ce79c6f44ec74720a4c2a17407],
      C: [0x985700efb6060e8f00d559014e2b80ab560caea19567bebc34dfbbb40c353a4, 0x1ab9f286231a52feeac6377d786e753ddb5bb8f7302ef9c68a16a4507df92dd5],
      C_p: [0x2202f0a24f97317a2e519ad19a8d68a7e30a27c21d663ef9912d7baf45b425d1, 0x2b175de94efa7cebfba7803e18052f3803eef7b2bccccd53833f3e4fafb0b212],
      H: [0x126f16c291f025d60ab2c945ab0def2e48a5dd60963c43e932e219eeaf063184, 0x2fa65fbc22833965848ee34c539a40944ff197e39a33cb4f5d40ee1fe599f5ae],
      K: [0x1869c99fd1a8116c5834be49061c6b1c0060cf09889495b39a192a1be57fda4f, 0xa42245f14bc48c92470dc838363f4d2307cb64e275e9fef3ad29141129c1635]
    };
    var input = [10, 1];
    return checkReturnVal(proof, input);
  });

});