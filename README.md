# Treasury

## Overview
The Treasury Smart Contract is designed to manage deposits, swaps, and yield farming across multiple stable coins using Uniswap and Aave protocols. The contract allows users to deposit stable coins, swap them through Uniswap, and supply them to the Aave lending pool. Additionally, it provides functionality to withdraw funds from Aave and calculates the aggregated yield for a specific stable coin.

## Features
* ```deposit```: Users can deposit stable coins into the Treasury contract, swap them through Uniswap and supply them to the Aave lending pool with a specified ratio.
* ```withdraw```: Allows users to withdraw stable coins from Aave.
* ```getAggregatedYield```: Calculates the aggregated yield for a specific stable coin.

## Setup
1. Clone the repository and navigate to the project directory:
```bash
git clone https://github.com/lexaisnotdead/Treasury-test.git
cd ./Treasury-test
```
2. Install the project dependencies:
```bash
npm install
```
3. Create a new ```.env``` file in the project directory with the following variables:
```bash
UNISWAP_V2_ROUTER_2 = <uniswap_v2_router_2_address>
AAVE_V3_POOL = <aave_v3_pool_address>
USDC = <usdc_address>
USDT = <usdt_address>
DAI = <dai_address>
INFURA_API_KEY = <your_infura_project_id>
PRIVATE_KEY = <your_private_key>
POLYSCAN_API_KEY = <your_polygonscan_api_key>
```

Replace ```USDC```, ```USDT``` and ```DAI``` with stablecoins addresses you want to use.

## Usage
To deploy the Treasury smart contract to a local network, execute the following commands:
```bash
npx hardhat run scripts/deploy-treasury.js --network localhost
```
Replace ```localhost``` with the name of the network you want to deploy to (e.g. goerli, mainnet, etc.) and make sure you have the corresponding configuration in the `hardhat.config.js` file.


## Links
[Link](https://mumbai.polygonscan.com/address/0x7B0a63C33F8d6D7d06f55A15747c4E4EefaD8d62#code) to the verified contract on the Polygon Mumbai