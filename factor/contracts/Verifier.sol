pragma solidity ^0.4.14;

import "./Pairing.sol";

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
    function verifyingKey() pure internal returns (VerifyingKey vk) {
        vk.A = Pairing.G2Point([0x2d456667c277bd56998238d5c25fb5952ccd725450c3445e2c22ccf5fe629b54, 0x509eac93e87ff385eb900158d8d7b43c0917d7d172b5bf68a4dd237195a91d5], [0x113f5988892345e3c6137736d875988576ff6dc0f2e8134ee297112fb579ae35, 0x260feff7fb1334db7b454c80b73a85663e85c039aef9513e64934f8ac1631f11]);
        vk.B = Pairing.G1Point(0x12bfed3a6f83df3a94fbb58ae7fa7fb99375c27abb8163cdcb71dac7c7e00306, 0x25f1b7069fec5f6cdbcd9c87555ed77c948786a86672017e04c18365a03cdc2a);
        vk.C = Pairing.G2Point([0x9fed05ef030de0c1e399b4d337f5e744f39ba6da6acd8f49d3e9b8dc8ca7c99, 0x1952e7e2a37922a5bd05088e96f07b87a727e49ad18799b67a305afe8ddb1239], [0x23d33966a0c42197b070b4cc1d497178b0076edb5b4e4c3067685cf09c19d6de, 0x15feb117e69b62e1a5a116cf065cff6d1579455580ce4ef77b59185215e8f3b8]);
        vk.gamma = Pairing.G2Point([0xe0fd8b392e569c916b9344e00dfe686d88cee1f99136a2800c27359e03c4910, 0x238c4b4487422fd1a564edda0f82aa2dd85c2f97d9781b6ecd3d1e44ecd08d7], [0x3b59d8a8bc0f5ce13c3a453c32c2edabcdfc3e4c2371defe75b1fd6c27c8d1e, 0xa521b3ce114a3fca67e2136611faafa4708ee651750ebe9697b4decb1b0e205]);
        vk.gammaBeta1 = Pairing.G1Point(0xcfa5c9f737e213231f15caa2f0b95659e62ec8be2636d6a97dc6a48606f61c9, 0x2aad773d7f0c5a0f258b02efd697af929e2c2087dc0b63e4afc6db1e3ad67fbd);
        vk.gammaBeta2 = Pairing.G2Point([0x2d51188207b352ef71135a565e3171f10fd4c7d568a8db300c87852367f94d27, 0x1de1cfe060ba133975fb33753fe04fec5ea38d80c6de8379ac67f109d0127444], [0x1ce3b0642a837a51676fea53907f00e36827a0743be0857b8f6c159114763460, 0x2420b402c9841b831e0a6bed05a224cf2c12f44daf60d4a5b92df54452cb39b1]);
        vk.Z = Pairing.G2Point([0x2938167399e9c8169bee9ed40b14033a6d23ee405b880937d7df58ddb85360be, 0xe9daf1d4ab5a55bc7283100420ea89bde17c2f6776cb113687ccc1aec5e990c], [0x2f48a684ff0bd7730b87515ba25bf88c3544b3a17435d766128c8f9676b9e3e6, 0x20c2ab48c11dfb6c9ded055f4b661a40e696fab6e25b70a7bd3065f6fb641a63]);
        vk.IC = new Pairing.G1Point[](3);
        vk.IC[0] = Pairing.G1Point(0x32743af5aa5809c8e6343da76d92dd43f7c15a692ddffb084ea61b4e70474af, 0x1eb75d085b9bbf0feb040cdda052614c5aa8204d4e520df69892ba0491c494e9);
        vk.IC[1] = Pairing.G1Point(0x167f6625f5c2c782daf7907d5afb10ce060874346461e009a1b5faacca7bb324, 0x1a24ff097a88b0ae300437cecc569bec4d4ac764a1c92893b9917298de10ff1d);
        vk.IC[2] = Pairing.G1Point(0x19be475b291374df9bac7d64d49a2fbd64c5675fc72ddeb0bf6635974de8e3cd, 0xa6ec9ff3b4d61621d4068189b323ea58b5ffeecf086d506d0b11242d0e7cb79);
    }
    function verify(uint[] input, Proof proof) internal returns (uint) {
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++)
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd2(proof.A, vk.A, Pairing.negate(proof.A_p), Pairing.P2())) return 1;
        if (!Pairing.pairingProd2(vk.B, proof.B, Pairing.negate(proof.B_p), Pairing.P2())) return 2;
        if (!Pairing.pairingProd2(proof.C, vk.C, Pairing.negate(proof.C_p), Pairing.P2())) return 3;
        if (!Pairing.pairingProd3(
            proof.K, vk.gamma,
            Pairing.negate(Pairing.addition(vk_x, Pairing.addition(proof.A, proof.C))), vk.gammaBeta2,
            Pairing.negate(vk.gammaBeta1), proof.B
        )) return 4;
        if (!Pairing.pairingProd3(
                Pairing.addition(vk_x, proof.A), proof.B,
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
        ) public returns (bool r) {
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
            emit Verified("Transaction successfully verified.");
            return true;
        } else {
            return false;
        }
    }
}