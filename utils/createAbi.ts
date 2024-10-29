import fs from "fs";
import { artifacts } from "hardhat";
import { resolve, join } from "path";
import { network } from "hardhat";

//  设置Api到本地文件夹中
export const createAbi = async (name: string, addr: string) => {

    //  获取合约信息
    const artifact = await artifacts.readArtifact(name);

    const data = {
        name:"",
        network:"",
        address:"",
        abi: {}
    };
    data["name"] = name;
    data["network"] = network.name;
    data["address"] = addr;
    data["abi"] = artifact.abi;
    await createContractFile(name, data);
}

//  创建文件
const createContractFile = async (fileName: string, data: any) => {
    const depPath = resolve(join(__dirname, "..", "abi"));
    // const depPath = resolve(join(__dirname, "..","..","vue_pro","src", "abi"));
    const exist = fs.existsSync(depPath)

    if (!exist) {
        fs.mkdirSync(depPath);
    }
    const fileNamePath = resolve(join(depPath, `${fileName}.json`));
    fs.writeFileSync(`${fileNamePath}`, JSON.stringify(data));
}