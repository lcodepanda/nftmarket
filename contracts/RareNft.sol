// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";


contract RareNft is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, VRFConsumerBaseV2 {

    using Strings for uint256;
    // //  token 
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    // chainlink 
    event RequestSent(uint256 requestId, uint32 numWords);
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;    //  subid
    bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;   //  请求最大的gas费
    uint32 callbackGasLimit = 1000000;   //  gas费上线 link
    uint16 requestConfirmations = 3;    //  等待区块
    uint32 numWords = 30;    //  请求多少随机数
    //      request    tokenId
    mapping(uint256 => uint256) requestIdToTokenId;
    constructor(
        uint64 subscriptionId, 
        address _mockAddress
    ) 
        ERC721("Random NFT", "RN") 
        VRFConsumerBaseV2(_mockAddress) 
    {
        COORDINATOR = VRFCoordinatorV2Interface(_mockAddress);
        s_subscriptionId = subscriptionId;

        _tokenIdCounter.increment();
    }

    function requestRandomWords(uint256 _tokenId) internal returns (uint256 requestId){
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,   //  subID
            requestConfirmations,   //  经过几个区块验证
            callbackGasLimit,
            numWords
        );
        requestIdToTokenId[requestId] = _tokenId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }
    //  接收到随机值的回调函数，本地模拟的话需要自己调用。链上由chainlink调用
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        uint random = _randomWords[0] % 100;
        uint256 tokenId = requestIdToTokenId[_requestId];
        // console.log(_setURI(tokenId), random);
        
        /**
         * b: 60%   1 = b
         * a: 30%   2 = a
         * c: 10%   3 = s
         */
        console.log(random);
        if(random < 60){
            _setTokenURI(tokenId, _setURI(1));
        }else if(random >= 60 && random < 90){
            _setTokenURI(tokenId, _setURI(2));
        }else if(random >= 90 && random <= 100){
            _setTokenURI(tokenId, _setURI(3));
        }

    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://raw.githubusercontent.com/qdwds/NFT-metadata/master/metadata/rare/json/";
    }
    
    function _setURI(uint256 _tokenId) internal pure returns(string memory uri) {
        uri = string(abi.encodePacked(_tokenId.toString(),".json"));
    }

    function safeMint(address to) public {
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(to, tokenId);
        // _setTokenURI(tokenId, uri);

        requestRandomWords(tokenId);
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