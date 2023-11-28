require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomicfoundation/hardhat-verify");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",

  networks: {
    localhost: {
      allowUnlimitedContractSize: true,
      timeout: 1800000,      
    },
    hardhat: {
      allowUnlimitedContractSize: true,
      timeout: 1800000,      
    },
    polygon_mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY],
    },
  },

  etherscan: {
    apiKey: process.env.POLYSCAN_API_KEY
  },
  sourcify: {
    enabled: true
  }
};
