Deploying using geth console takes 2 steps:

1. Complile using solidity compliler and put the output in a variable in a js file (`temp-compile-contract.js`).
2. Load the js script in console so that the console has access to the variable (`compiled`) holding the compiled contract.

Examples of a deployments

* For MyToken.sol
  * Compile contract to a js file
    ```bash
    echo "var compiled=`solc --optimize --combined-json abi,bin MyToken.sol`" > temp-compile-contract.js
    ```

  * Deploy instructions from geth console
    ```javascript
    primaryAddress = eth.accounts[0]
    loadScript('./temp-compile-contract.js')
    abi = JSON.parse(compiled.contracts["MyToken.sol:MyToken"].abi)
    bincode = "0x"+compiled.contracts["MyToken.sol:MyToken"].bin
    NewTokIfc = eth.contract(abi)
    contract = NewTokIfc.new(10000, "NewToken", 2, "%", {from: primaryAddress, data: bincode, value: 100000000000000000000, gas: 2100000})
    ```

* For MyToken2.sol
  * Compile contract to a js file
    ```bash
    echo "var compiled=`solc --optimize --combined-json abi,bin MyToken2.sol`" > temp-compile-contract.js
    ```

  * Deploy instructions from geth console
    ```javascript
    primaryAddress = eth.accounts[0]
    loadScript('./temp-compile-contract.js')
    abi = JSON.parse(compiled.contracts["MyToken2.sol:MyToken"].abi)
    bincode = "0x"+compiled.contracts["MyToken2.sol:MyToken"].bin
    NewTokIfc2 = eth.contract(abi)
    contract2 = NewTokIfc.new(10000, "NewToken2", 2, "%", primaryAddress, 1, 2, {from: primaryAddress, data: bincode, value: 100000000000000000000, gas: 2100000})
    ```

* For MyToken3.sol
  * Compile contract to a js file
    ```bash
    echo "var compiled=`solc --optimize --combined-json abi,bin MyToken3.sol`" > temp-compile-contract.js
    ```

  * Deploy instructions from geth console
    ```javascript
    primaryAddress = eth.accounts[0]
    loadScript('./temp-compile-contract.js')
    abi = JSON.parse(compiled.contracts["MyToken2.sol:MyToken"].abi)
    bincode = "0x"+compiled.contracts["MyToken2.sol:MyToken"].bin
    NewTokIfc3 = eth.contract(abi)
    contract3 = NewTokIfc3.new(10000, "NewToken3", 2, "%", primaryAddress, 1, 2, 1000, {from: primaryAddress, data: bincode, value: 100000000000000000000, gas: 2100000})
    ```

To see the contract in Ethereum wallet, get the contact address as `contract.address` and the json interface as `JSON.stringify(abi)`.