pragma solidity ^0.4.14;

import './verifier.sol';
contract SumsToFifteen is Verifier {
    bool public success = false;
    event Trace0(string);
    function verifyFifteen(
        uint[2] a,
        uint[2] a_p,
        uint[2][2] b,
        uint[2] b_p,
        uint[2] c,
        uint[2] c_p,
        uint[2] h,
        uint[2] k,
        uint[2] input) public {
        emit Trace0(">>>-1");
        // Verifiy the proof
        success = verifyTx(a, a_p, b, b_p, c, c_p, h, k, input);
        //if (success) {
            // Proof verified
        //} else {
            // Sorry, bad proof!
        //}
    }

    function get() constant returns (bool retVal) {
        return success;
    }
}