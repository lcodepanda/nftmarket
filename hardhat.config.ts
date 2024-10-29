import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import {config as dotenvConfig} from "dotenv";
dotenvConfig()




const config: HardhatUserConfig = {
    solidity: "0.8.19",
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            // forking: {
            //     url: "https://eth.llamarpc.com"
            // },
            mining: {
                auto: false,
                interval: 5000
            }
        },
        goeril:{
            url:"https://rpc.ankr.com/eth_goerli",
            accounts:[process.env.PROVITEKEY!]
        },
    }
};

export default config;
