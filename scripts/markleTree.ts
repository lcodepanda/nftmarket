import { keccak256 } from "ethers/lib/utils";
import { ethers } from "hardhat"
import { MerkleTree } from "merkletreejs";
const white = [
    "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
    "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
    "0x90F79bf6EB2c4f870365E785982E1f101E93b906"
]
const main = async ()=> {
    // 生成MerkleTree
    const leaf = white.map(x => keccak256(x));
    const markletree = new MerkleTree(leaf, keccak256, {sortPairs: true});
    const root = markletree.getHexRoot();
   

    // 部署合约
    const MarkleTree = await ethers.getContractFactory("MarkleTree");
    const tree = await MarkleTree.deploy(root);
    console.log(tree.address);
    await tree.deployed();

    // 白名单 mint
    for (let i = 0; i < white.length; i++) {
        const proof = markletree.getHexProof(leaf[i]);
        await tree.mint(white[i], proof);
        console.log(await tree.whiteLists(white[i]));
    }


    //  不存在的白名单 会报错
    const proof = markletree.getHexProof(leaf[0]);
    await tree.mint("0x71bE63f3384f5fb98995898A86B02Fb2426c5788", proof);

}

main()
    .catch(err =>{
        console.log(err);
        process.exit(1);
    })