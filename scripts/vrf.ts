
import { parseUnits } from "ethers/lib/utils";
import { ethers } from "hardhat";
const baseFee = parseUnits("0.0001");   //  节点调用的费用
const gasPriceLink = parseUnits("1","gwei");   //  节点调用的费用


const vrf = async() =>{
    const Mock = await ethers.getContractFactory("VRFCoordinatorV2Mock");
    const mock = await Mock.deploy(
        baseFee,
        gasPriceLink
    )
    await mock.deployed();

    const tx = await mock.createSubscription();
    const txReceipt:any = await tx.wait(1);
    const subId = txReceipt.events[0].topics[1];

    // 模拟充值link
    await mock.fundSubscription(subId, parseUnits("10000"));

    const VRF = await ethers.getContractFactory("VRF");
    const vrf = await VRF.deploy(subId, mock.address);
    await vrf.deployed();

    await mock.addConsumer(subId, vrf.address);
    console.log(mock.address);
    console.log(vrf.address);
    
    const result = await vrf.requestRandomWords();
    const vrfTx:any = await result.wait(4);

    const requestId = vrfTx.events[1].args[0];

    await mock.fulfillRandomWords(requestId, vrf.address);
}


vrf()
    .catch(err =>{
        console.log(err);
        process.exit(1);
    })