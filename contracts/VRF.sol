// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "hardhat/console.sol";
contract VRF is  VRFConsumerBaseV2 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    VRFCoordinatorV2Interface COORDINATOR;

    event RequestSent(uint256 requestId, uint32 numWords);

    uint64 s_subscriptionId;    //  subid
    bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;   //  请求最大的gas费
    uint32 callbackGasLimit = 1000000;   //  gas费上线 link
    uint16 requestConfirmations = 3;    //  等待区块
    uint32 numWords = 30;    //  请求多少随机数


    constructor(uint64 subscriptionId, address _mockAddress) VRFConsumerBaseV2(_mockAddress) {
        COORDINATOR = VRFCoordinatorV2Interface(_mockAddress);
        s_subscriptionId = subscriptionId;
    }


    // 请求随机数
    function requestRandomWords()external returns (uint256 requestId){
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,   //  subID
            requestConfirmations,   //  经过几个区块验证
            callbackGasLimit,
            numWords
        );
        emit RequestSent(requestId, numWords);
        return requestId;
    }
    //  接收到随机值的回调函数，本地模拟的话需要自己调用。链上由chainlink调用
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
       for(uint i = 0; i < _randomWords.length; i++){
            console.log(_randomWords[i]);
       }
    }

}
