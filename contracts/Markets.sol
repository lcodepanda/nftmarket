// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import  "./ComposeNFT.sol";


contract Markets {
    using Counters for Counters.Counter;
    Counters.Counter private indexCounter;

    struct Market {
        address seller;
        uint256 tokenId;
        uint256 index;
        uint256 price;
        string uri;
        bool active;
    }
    Market[] public markets;
    mapping (uint256 => Market) tokenIdToMatket;
    mapping (address => uint) tokenIdToPrice;
    ComposeNFT compose;
    constructor(ComposeNFT _compose) {
        compose = _compose;
    }

    function hashActive(uint256 _tokenId) public view returns (bool) {
        return tokenIdToMatket[_tokenId].active;
    }
    //上架
    function shelve(uint256 _tokenId, uint256 _price) public {
        require(compose.ownerOf(_tokenId) == msg.sender, "The is Owner?");
        require(!hashActive(_tokenId), "Alread on shelves");
        require(
            IERC721(compose).getApproved(_tokenId) == address(this)|| 
            IERC721(compose).isApprovedForAll(msg.sender, address(this)),
            "No approve"
        );

        uint256 index = indexCounter.current();
        indexCounter.increment();

        string memory uri = compose.tokenURI(_tokenId);
        Market memory newMarket = Market(
            msg.sender,
            _tokenId,
            index,
            _price,
            uri,
            true
        );
        markets.push(newMarket);
        tokenIdToMatket[_tokenId] = newMarket;
    }
    function unShelve(uint256 _tokenId) public {
        require(compose.ownerOf(_tokenId) == msg.sender, "Ths is owner");
        require(hashActive(_tokenId), "Removed from shelves");

        _unShelve(_tokenId);
    }
    
    function _unShelve(uint256 _tokenId) internal {
        Market memory market = tokenIdToMatket[_tokenId];
        delete markets[market.index];
        delete tokenIdToMatket[_tokenId];
    }

    function allMarkets() public view returns(Market[] memory allMarkets) {
        if(markets.length == 0){
            return new Market[](0);
        }

        uint256 count = 0;
        for (uint i = 0; i < markets.length; i++) {
            Market memory market = markets[i];
            if(market.active){
                count ++;
            }
        }

        uint j = 0;
        allMarkets = new Market[](count);
        for (uint i = 0; i < markets.length; i++) {
            if(markets[i].active){
                allMarkets[j] = markets[i];
                j++;
            }
            if(j >= count){
                return allMarkets;
            }
        }
    }


    function buy(uint256 _tokenId) public payable{
        Market memory  market = tokenIdToMatket[_tokenId];
        require(msg.value >= market.price, "Price error");
        require(msg.sender != market.seller,"Address error");
        require(market.active,"No market");

        _unShelve(_tokenId);

        tokenIdToPrice[market.seller] = msg.value;

        compose.safeTransferFrom(market.seller, msg.sender, _tokenId);
    }

    function withdraw() public {
        uint balance = tokenIdToPrice[msg.sender];
        require(balance > 0,"No price");
        tokenIdToPrice[msg.sender] = 0;

        (bool sent,) = msg.sender.call{value: balance}("");
        require(sent, "withdraw error");
    }
}