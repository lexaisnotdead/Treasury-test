const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
  const accounts = await ethers.getSigners();
  
  console.log(
      "Deploying contracts with the account:",
      accounts[0].address
  );
  console.log("Account balance:", (await ethers.provider.getBalance(accounts[0].address)).toString());

  const uniswapRatio = 50;
  const aaveRatio = 50;

  const uniswapV2Router2 = process.env.UNISWAP_V2_ROUTER_2;
  const aaveV3Pool = process.env.AAVE_V3_POOL;

  const whitelist = [
    process.env.USDC,
    process.env.USDT,
    process.env.DAI
  ];

  const Treasury = await ethers.getContractFactory("Treasury");
  const treasuryContract = await Treasury.deploy(uniswapRatio, aaveRatio, uniswapV2Router2, aaveV3Pool, whitelist);
  await treasuryContract.waitForDeployment();
  
  console.log("Treasury contract deployed to:", treasuryContract.target);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
