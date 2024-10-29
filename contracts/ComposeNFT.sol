// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ComposeNFT is ERC721, ERC721Enumerable, ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    struct Donkey {
        address owner;
        uint tokenId;
        uint8 level;
        uint dadId;
        uint mumId;
        string uri;
    }
    Donkey[] public donkeys;
    constructor() ERC721("Compsoe NFT ", "CN") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://raw.githubusercontent.com/qdwds/NFT-metadata/master/metadata/donkeys/";
    }
    function _setURI(uint256 _level) internal view  returns (string memory uri) {
        uint random = _random(100);
        uri  = string(abi.encodePacked(_level.toString(), "/images/",random.toString(),".png"));
    }
    
    function _random(uint _max) internal view returns(uint256) {
        uint random = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.coinbase, gasleft())));
        return (random > block.number ) ? (random - block.number) % _max : (block.number - random) % _max;
    }

    function safeMint(address _to) public {
        _interSafeMint(_to,0,0,0);
    }

    function batchSafeMint(address _to, uint8 _val) public {
        require(_val <= 10,"MAX 10");
        for (uint i = 0; i < _val; i++) {
            _interSafeMint(_to,0,0,0);
        }
    }
    function _interSafeMint(address _to, uint8 _level, uint256 _dadId, uint256 _mumId) internal {
        uint256 tokenId =_tokenIdCounter.current();
        _tokenIdCounter.increment();

        string memory uri = string(abi.encodePacked(_baseURI(), _setURI(_level)));

        Donkey memory donkey = Donkey(
            _to,
            tokenId,
            _level,
            _dadId,
            _mumId,
            uri
        );
        donkeys.push(donkey);
        
        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, _setURI(_level));
    }

    function getDonkey(uint256 _tokenId) public view returns(Donkey memory donkey) {
        donkey = donkeys[_tokenId];
    }

    function getDonkeys(address _owner) public view returns(Donkey[] memory ownerDonkey) {
        uint balance = balanceOf(_owner);
        ownerDonkey = new Donkey[](balance);
        for (uint i = 0; i < balance; i++) {
            uint index = tokenOfOwnerByIndex(_owner, i);
            ownerDonkey[i] = donkeys[index];
        }
    }

    function breed(uint _dadId, uint _mumId) public  {
        Donkey memory dad = donkeys[_dadId];
        Donkey memory mum = donkeys[_mumId];
        require(dad.owner == msg.sender && mum.owner == msg.sender, "Owner ?");
        require(dad.level == mum.level, "Level fild");
        require(dad.level < 3,"MAX NFT level 3");
        _interSafeMint(msg.sender, dad.level + 1, dad.tokenId, mum.tokenId);
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