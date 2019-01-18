Web3 = require("../../factor/node_modules/web3/");

if (typeof web3 !== 'undefined') {
  web3 = new Web3(web3.currentProvider);
} else {
  // set the provider you want from Web3.providers
  web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
}


var abi = [{"constant":true,"inputs":[],"name":"success","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"data","type":"bytes32"}],"name":"bytes32ToString","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"a","type":"uint256[2]"},{"name":"a_p","type":"uint256[2]"},{"name":"b","type":"uint256[2][2]"},{"name":"b_p","type":"uint256[2]"},{"name":"c","type":"uint256[2]"},{"name":"c_p","type":"uint256[2]"},{"name":"h","type":"uint256[2]"},{"name":"k","type":"uint256[2]"},{"name":"input","type":"uint256[2]"}],"name":"verifyTx","outputs":[{"name":"r","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"name":"","type":"string"}],"name":"Trace0","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"","type":"string"}],"name":"Trace","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"","type":"string"},{"indexed":false,"name":"","type":"string"}],"name":"Trace1","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"","type":"string"}],"name":"Verified","type":"event"},{"constant":false,"inputs":[{"name":"a","type":"uint256[2]"},{"name":"a_p","type":"uint256[2]"},{"name":"b","type":"uint256[2][2]"},{"name":"b_p","type":"uint256[2]"},{"name":"c","type":"uint256[2]"},{"name":"c_p","type":"uint256[2]"},{"name":"h","type":"uint256[2]"},{"name":"k","type":"uint256[2]"},{"name":"input","type":"uint256[2]"}],"name":"verifyFifteen","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"}]
var VerifierContract = web3.eth.contract(abi).at("0xE433B29c01e6Fdb74fd283F3e087cea6171B17d7");
// console.log(VerifierContract);

// var VerifierContract = new web3.eth.Contract(abi, "0xA7b3B52e949dA61DB5CF894C9d7059A93d06E3F9");

A = [0x17ae0464d4c0d1937fee027b520ca9ec7ee4f2abf70b52a75c636d6735005392, 0x281134f906ab1cb3011cb6207a1f9ef5398045af52c3eff8e9db9f50c8cf3828]
A_p = [0x1ac693cdd14a1206f930729a929b3b39721f838446061af6311c4ed30c428426, 0x2712e90c78ec9e0e5ccf3356e23855484c4073bb274194635b612b63f4ac8be3]
B = [[0x883a4f310a3966a5cb139b59288c78aa8a8a9a8b4bf48792420d5184f8fb8b5, 0x201d60787fd856c24e7b45dab7cb41a79ff348153683dbf82b5d77d14e168ae5], [0x1d9ccf0e5d091b85a795d74abc13625e531cb65115589b999c9c0e05b7310920, 0x21a3beba1014556c091197668c9380cc37e420b4232fa5c35a175ee00bfe92f4]]
B_p = [0x1d0c580e2431894c97e6bee5de2e396477beabebeb4606c21d241328d0ca139d, 0x2add4d48ef20738cf6540cc530bf80948bd6cb8b180cf4a3ec412e0dc58fe3de]
C = [0x20ba1cacf4ebbc3c1c29d11946b1c38151cb44d0803d628fa69e1ae8e930e7c7, 0x1dc6686abe23aa65b1653fab516386b86d7deae2ac817cf7fb3d89ad4d1da8ca]
C_p = [0xb292b7ab8b91c84eb61338fa9837465d94e3e82c1e029c55b4d754161242b13, 0x15f60d3a7192a31f6da6804e960cbd13198a710f14c4860fd5ea1453eb2cf131]
H = [0x2621bd887a4e502ae5d9660a56702be8a7567bee0507d8af711be5fca888ff88, 0x2e905b72b811929ea2475d8c0df0a5815e329aebe787a37cf62a60ba4dad0c5c]
K = [0xf1bd7f2d6fe7efcb5480bd8743c359153dc73153039f0c76c90b62431ca1ac2, 0x151b78bf375d6d20a2f242e70db41d25183a594632e553f97d27570d15551ff]

var I = [5, 1]

function transform(arg) {
  if (arg.constructor === Array) {
    if (arg[0].constructor === Array) {
      for (var i = 0; i < arg.length; i++) {
        for (var j = 0; j < arg[0].length; j++) {
          arg[i][j] = arg[i][j].toString();
        }
      }

    } else {
      for (var i = 0; i < arg.length; i++) {
        arg[i] = arg[i].toString();
      }
    }
  } 
}

// transform(A);
// transform(A_p);
// transform(B);
// transform(B_p);
// transform(C);
// transform(C_p);
// transform(H);
// transform(K);

var result = VerifierContract.verifyFifteen(A, A_p, B, B_p, C, C_p, H, K, I, { from: web3.eth.accounts[0], gas: 2100000});
console.log("proof: "+web3.eth.getTransaction(result).value)

console.log("success: "+VerifierContract.get())