import { parseUnits } from "ethers/lib/utils";
import { ethers } from "hardhat";

const main = async() =>{
    const [acc1] = await ethers.getSigners();
    const Mock = await ethers.getContractFactory("VRFCoordinatorV2Mock");
    const mock = await Mock.deploy(
        parseUnits("0.0001"),
        parseUnits("1","gwei")
    )
    await mock.deployed();
    
    const mockTx = await mock.createSubscription();
    const mockReceipt:any = await mockTx.wait(1);
    const subId = mockReceipt.events[0].topics[1];

    // 模拟充值link
    await mock.fundSubscription(subId, parseUnits("10000"));

    const RareNFT = await ethers.getContractFactory("RareNft");
    const rareNFT = await RareNFT.deploy(subId, mock.address);
    await rareNFT.deployed();


    //  添加订阅
    await mock.addConsumer(subId, rareNFT.address);
    
    //  mint
    for (let i = 1; i < 10; i++) {
        const mintTx = await rareNFT.safeMint(acc1.address);
        const randomReceipt:any = await mintTx.wait(4);
        
        // 获取requestId；
        const requestId = randomReceipt.events[2].args[0];

        // 手动调用返回随机数
        await mock.fulfillRandomWords(requestId, rareNFT.address);
        
        console.log( await rareNFT.tokenURI(i));
        
    }
}


main()
    .catch(err =>{
        console.log(err);
        process.exit(1);
    })