pragma solidity ^0.4.8;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender != owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract MyToken is owned {
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    
    string public name;
    string public symbol;
    uint8 public decimals;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyToken(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        address centralMinter,
        uint256 sellPrice, 
        uint256 buyPrice
        ) payable {
        if (centralMinter != 0) owner = centralMinter;
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
        
        // Calling public method from constructor is not correct as a public function can only be called after the contract is successfully deployed
        //this.setPrices(sellPrice, buyPrice);
        
        // Seeting the prices
        // sellPrice = sellPrice;
        // buyPrice = buyPrice;
        // PricesSet(sellPrice, buyPrice, owner);
        _setPrices(sellPrice, buyPrice);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        /* Check if sender has balance and for overflows */
        require (balanceOf[msg.sender] >= _value && balanceOf[_to] + _value >= balanceOf[_to]);

        require(!frozenAccount[msg.sender]);

        /* Add and subtract new balances */
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        /* Notify anyone listening that this transfer took place */
        Transfer(msg.sender, _to, _value);
    }

    uint256 public totalSupply;

    function mintToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, owner, mintedAmount);
        Transfer(owner, target, mintedAmount);
    }

    mapping (address => bool) public frozenAccount;
    
    event FrozenFunds(address target, bool frozen);

    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    uint256 public sellPrice;
    uint256 public buyPrice;

    event PricesSet(uint256 newSellPrice, uint256 newBuyPrice, address setter);

    function _setPrices(uint256 newSellPrice, uint256 newBuyPrice) internal {
        // So it can be called from constructor
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
        PricesSet(sellPrice, buyPrice, owner);
    }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
        _setPrices(newSellPrice, newBuyPrice);
    }

    /* Called by someone buying some tokens by sending ether to this contract. 
    Results in decrease of token balance of contract and increase in it's ether 
    balance, opposite happens for token buyer
    */
    function buy() payable returns (uint amount){
        amount = msg.value / buyPrice;                     // calculates the amount
        require(balanceOf[this] >= amount);               // checks if it has enough to sell
        balanceOf[msg.sender] += amount;                   // adds the amount to buyer's balance
        balanceOf[this] -= amount;                         // subtracts amount from seller's balance
        Transfer(this, msg.sender, amount);                // execute an event reflecting the change
        return amount;                                     // ends function and returns
    }

    /* Called by someone selling some tokens and receiving ether from this 
    contract. Results in increase of token balance of contract and decrease in it's ether 
    balance, opposite happens for token buyer
    */
    function sell(uint amount) returns (uint revenue){
        require(balanceOf[msg.sender] >= amount);        // checks if the sender has enough to sell
        balanceOf[this] += amount;                         // adds the amount to owner's balance
        balanceOf[msg.sender] -= amount;                   // subtracts the amount from seller's balance
        revenue = amount * sellPrice;
        require(msg.sender.send(revenue));
        Transfer(msg.sender, this, amount);             // executes an event reflecting on the change
        return revenue;                                 // ends function and returns
    }
}