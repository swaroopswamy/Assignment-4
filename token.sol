//0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B

pragma solidity ^0.8.0;

contract TokenSale {
    address public owner;
    uint256 public tokensForSale;
    uint256 public tokensSold;
    uint256 public price;
    bool public saleActive;
    mapping(address => uint256) public balances;

    event SaleStarted(uint256 tokensForSale, uint256 price);
    event TokensPurchased(address buyer, uint256 tokens);
    event SaleEnded(uint tokensSold);

    constructor(uint256 _tokensForSale, uint256 _price) {
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

    function buyTokens(uint256 _tokens) public payable {
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

        uint256 tokens = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(tokens * price);
    }
}
