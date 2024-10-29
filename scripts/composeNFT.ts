import { ethers } from "hardhat";
import { createAbi } from "../utils/createAbi";

const main = async () => {

    const ComposeNFT = await ethers.getContractFactory("ComposeNFT");
    const compose = await ComposeNFT.deploy();
    await compose.deployed();

    console.log(compose.address);
    createAbi("ComposeNFT", compose.address);
}

main()
    .catch(err =>{
        console.log(err);
        process.exit(1);
    })
    