// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


contract MarkleTree is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    //  默克尔树
    bytes32 internal immutable root;
    // 白名单列表
    mapping(address => bool) public  whiteLists;

    constructor(bytes32 _root) ERC721("MyToken", "MTK") {
        root = _root;
    }

   function mint(address account, bytes32[] calldata proof) public {
        require(_verify(_leaf(account), proof), "Invalid merkle proof");
        require(!whiteLists[account], "Already minted");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        whiteLists[account] = true;
        _mint(account, tokenId);
   }

    // 计算默克尔树叶子的哈希值
   function _leaf(address account) internal  pure returns(bytes32) {
       return  keccak256(abi.encodePacked(account));
   }

    // 验证
    function _verify(bytes32 leaf, bytes32[] memory proof) internal  view returns (bool){
        return  MerkleProof.verify(proof, root, leaf);
    }

}