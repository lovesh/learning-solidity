pragma solidity ^0.4.14;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() internal returns (G1Point) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() internal returns (G2Point) {
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }
    /// @return the negation of p, i.e. p.add(p.negate()) should be zero.
    function negate(G1Point p) internal returns (G1Point) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return the sum of two points of G1
    function add(G1Point p1, G1Point p2) internal returns (G1Point r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 6, 0, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid }
        }
        require(success);
    }
    /// @return the product of a point on G1 and a scalar, i.e.
    /// p == p.mul(1) and p.add(p) == p.mul(2) for all points p.
    function mul(G1Point p, uint s) internal returns (G1Point r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 7, 0, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] p1, G2Point[] p2) internal returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 8, 0, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point a1, G2Point a2, G1Point b1, G2Point b2) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point a1, G2Point a2,
            G1Point b1, G2Point b2,
            G1Point c1, G2Point c2
    ) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point a1, G2Point a2,
            G1Point b1, G2Point b2,
            G1Point c1, G2Point c2,
            G1Point d1, G2Point d2
    ) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}
contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G2Point A;
        Pairing.G1Point B;
        Pairing.G2Point C;
        Pairing.G2Point gamma;
        Pairing.G1Point gammaBeta1;
        Pairing.G2Point gammaBeta2;
        Pairing.G2Point Z;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G1Point A_p;
        Pairing.G2Point B;
        Pairing.G1Point B_p;
        Pairing.G1Point C;
        Pairing.G1Point C_p;
        Pairing.G1Point K;
        Pairing.G1Point H;
    }
    function verifyingKey() internal returns (VerifyingKey vk) {
        vk.A = Pairing.G2Point([0x2f66e7ff688469322c2254b8bbc0e0fdbf7d1724fac53cdba8c9969a16d9d9d9, 0x1a62450c530315eeadab091a64aa395eaf393a1dc10cdfb83537b902c971c707], [0x1b6cf2c7469f81b217f33be0a6cd9abcabd229e9dcabcdcbbd6f7460198ff845, 0x1dd070f36af8b77967bab6e772b4d1cf23cfa1f94bbd768b9587131f65def8d]);
        vk.B = Pairing.G1Point(0xefc4761f3e44ef7edb536e906511c1d25236a0fdd7ceecce0acda3fd15edb7b, 0x26b985370f3bb9002699e1957104d30ffe2f31e05cdfd66630e4a1d73c3be686);
        vk.C = Pairing.G2Point([0x19e9c6a4a0e7ff88bcbc91e2c7c15fa75b9ddba23fbacab0aa97bec1fb70d953, 0x1df3c2162a1662bceacbf359f3a4a202924c6cdc6bd716ad3b67640066c0dc10], [0xd433f92acbc2e5cab812e5d9a5d8777fbe893c8e7706b0c0158d73d952d4222, 0xc3849213d40741ebfe767f02bcd7da911670ad011ed4ddb3099d919b345dc6b]);
        vk.gamma = Pairing.G2Point([0x1d807519887eb1a0677889edf1fa8d469c28cab218217b257730b97f4bf0175f, 0x24d154e99397210bd547665fb932c4b100ff432e36861e64f5e0ba0928b34cf3], [0x1ee5610f378d97c83295de0aeb385d56a6858fa972d46d7c72c6d0ef5e9c2aa0, 0x19e96768cd1ba3f86e9df221032e7634e9a635d42f8e223906063d1338d6cbf9]);
        vk.gammaBeta1 = Pairing.G1Point(0xc97ba7bacc77e3da24e42b26c6b744f6e4fd6dfac5f4b47a51822da3261ac83, 0x204f7bfb6c99f43e69583ef7546160ca291fc18e248686c9c14fe54410becfc7);
        vk.gammaBeta2 = Pairing.G2Point([0x2a2728c19b73c4a74a920091f4476c59c24a226b3e2cb558fee3b611495262a5, 0xcd3360753368467914a7ef9469a097254ad888533adaff5ba7b8b5a15162ae0], [0xe6a2db53c0f7d8299ca24dcdf9c6ea7add0959ecb961dffbcb5c6c5a7f875f, 0x19704420c5236c1a25fa69372dd6414c54f50cd5a571aa3b4d3803a44baae628]);
        vk.Z = Pairing.G2Point([0x104de5eca71d065754305f2b9a4514fff58a2f2ce41c2be20c7da6457432903, 0x2eb4478a028ee5cabf9985d49875e1cb6ba7bf83dec01ebe3d3cd5f81e921692], [0x178d8c34ecbef20c5eb490067ab177341443302f46f9f793d7991f0b98df6593, 0xd82b1a8d5797463df9acd3c297f3bc17e653ee932ab7dc5a11907caea74a449]);
        vk.IC = new Pairing.G1Point[](3);
        vk.IC[0] = Pairing.G1Point(0xbaba5f191ca0f6c31bcc227627a53b0df8c27847c9143b22f4d010e092ec453, 0x17da81fe6bb2de228f6f8d2f55f6ef0ffbf846d6354051924aaca1f86daf1b39);
        vk.IC[1] = Pairing.G1Point(0x108e8503681a49c3f1cbbc992c4eea806c4aaefb6fb9d4ad42d137c78634bdd6, 0x98265dbcdbcd898a020751a92488e49e5f6c6269fa94b588e533225c7bef666);
        vk.IC[2] = Pairing.G1Point(0x25feb1b66e389461bbef0b975bed920a275ba4000300a5f246ee919a2bfaeade, 0x1c8526385efd023fc71401e77dc3018a8448cf07467a7fb3883d3e41bfeb4bc5);
    }
    function verify(uint[] input, Proof proof) internal returns (uint) {
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++)
            vk_x = Pairing.add(vk_x, Pairing.mul(vk.IC[i + 1], input[i]));
        vk_x = Pairing.add(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd2(proof.A, vk.A, Pairing.negate(proof.A_p), Pairing.P2())) return 1;
        if (!Pairing.pairingProd2(vk.B, proof.B, Pairing.negate(proof.B_p), Pairing.P2())) return 2;
        if (!Pairing.pairingProd2(proof.C, vk.C, Pairing.negate(proof.C_p), Pairing.P2())) return 3;
        if (!Pairing.pairingProd3(
            proof.K, vk.gamma,
            Pairing.negate(Pairing.add(vk_x, Pairing.add(proof.A, proof.C))), vk.gammaBeta2,
            Pairing.negate(vk.gammaBeta1), proof.B
        )) return 4;
        if (!Pairing.pairingProd3(
                Pairing.add(vk_x, proof.A), proof.B,
                Pairing.negate(proof.H), vk.Z,
                Pairing.negate(proof.C), Pairing.P2()
        )) return 5;
        return 0;
    }
    event Verified(string);
    function verifyTx(
            uint[2] a,
            uint[2] a_p,
            uint[2][2] b,
            uint[2] b_p,
            uint[2] c,
            uint[2] c_p,
            uint[2] h,
            uint[2] k,
            uint[2] input
        ) returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.A_p = Pairing.G1Point(a_p[0], a_p[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.B_p = Pairing.G1Point(b_p[0], b_p[1]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        proof.C_p = Pairing.G1Point(c_p[0], c_p[1]);
        proof.H = Pairing.G1Point(h[0], h[1]);
        proof.K = Pairing.G1Point(k[0], k[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            Verified("Transaction successfully verified.");
            return true;
        } else {
            return false;
        }
    }
}
