// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract TrendsNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint8;
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Trends NFT", "TN") {}
    mapping(uint256 => string) tokenIdToData;
    struct NFT{
        string uri;
        string data;
    }
    receive() external payable {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://raw.githubusercontent.com/qdwds/NFT-metadata/master/metadata/trends/json/";
    }
    
    function safeMint(address _to) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, _setURI(0));
    }

    function write(uint256 _tokenId, string memory _data)public payable {
        require(msg.value >= 0.01 ether, "EHT 0.01");
        require(ownerOf(_tokenId) == msg.sender,"N");
        tokenIdToData[_tokenId] = _data;
         _setTokenURI(_tokenId, _setURI(1));
    }

    function clean(uint256 _tokenId) public payable {
        require(msg.value >= 0.01 ether, "EHT 0.01");
        address account = ownerOf(_tokenId);
        require(account == msg.sender, "N");
        tokenIdToData[_tokenId] = "";
        _setTokenURI(_tokenId, _setURI(0));
    }

    function _setURI(uint8 _index) internal pure returns(string memory uri){
         uri = string(abi.encodePacked(_index.toString(),".json"));
    }


    function withdraw(address to) public payable onlyOwner{
        to.call{value:address(this).balance}("");
    }
    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}