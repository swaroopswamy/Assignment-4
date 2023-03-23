pragma solidity ^0.8.0;

contract TokenSale {
    address public owner;
    uint public tokensForSale;
    uint public tokensSold;
    uint public price;
    bool public saleActive;
    mapping(address => uint) public balances;

    event SaleStarted(uint tokensForSale, uint price);
    event TokensPurchased(address buyer, uint tokens);
    event SaleEnded(uint tokensSold);

    constructor(uint _tokensForSale, uint _price) {
        owner = msg.sender;
        tokensForSale = _tokensForSale;
        price = _price;
        saleActive = false;
    }

    function startSale() public {
        require(msg.sender == owner,"Only the owner can start the sale.");
        require(!saleActive,"The sale has already started.");

        saleActive = true;
        emit SaleStarted(tokensForSale, price);
    }

    function buyTokens(uint _tokens) public payable {
        require(saleActive,"The sale is not active.");
        require(_tokens > 0,"You must purchase at least one token.");
        require(tokensSold + _tokens <= tokensForSale,"There are not enough tokens left for sale.");
        require(msg.value == _tokens * price,"You must send enough ether to purchase the requested number of tokens.");

        tokensSold += _tokens;
        balances[msg.sender] += _tokens;
        emit TokensPurchased(msg.sender, _tokens);
    }

    function endSale() public {
        require(msg.sender == owner,"Only the owner can end the sale.");
        require(saleActive,"The sale is not active.");

        saleActive = false;
        emit SaleEnded(tokensSold);
    }

    function withdraw() public {
        require(balances[msg.sender] > 0,"You have no tokens to withdraw.");

        uint tokens = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(tokens * price);
    }
}