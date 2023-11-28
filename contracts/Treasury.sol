// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";

contract Treasury is Ownable {
    mapping (address => bool) public whitelist;
    mapping (address => uint256) public deposits;

    IUniswapV2Router02 public uniswapV2Router;
    IPool public aaveLendingPool;

    uint256 public uniswapRatio;
    uint256 public aaveRatio;

    event NewRatio(
        uint256 indexed oldUniswapRatio, uint256 indexed newUniswapRatio,
        uint256 oldAaveRatio, uint256 newAaveRatio
    );
    event NewStabeleCoin(address stableCoin);
    event StableCoinRemoved(address stableCoin);
    event Swap(address indexed stableCoinIn, address indexed stableCoinOut, uint256 indexed amountIn);
    event Supply(address indexed stableCoin, uint256 indexed amount);
    event Withdraw(address indexed stablecoin, uint256 amount);

    constructor(
        uint256 _uniswapRatio,
        uint256 _aaveRatio,
        address _uniswapV2Router,
        address _aaveLendingPool,
        address[] memory _whitelist
    ) Ownable(msg.sender) {
        require(_uniswapRatio + _aaveRatio == 100);
        uniswapRatio = _uniswapRatio;
        aaveRatio = _aaveRatio;

        uniswapV2Router = IUniswapV2Router02(_uniswapV2Router);
        aaveLendingPool = IPool(_aaveLendingPool);

        for (uint256 i = 0; i < _whitelist.length; ++i) {
            require(_whitelist[i] != address(0));

            whitelist[_whitelist[i]] = true;
        }
    }

    modifier whitelisted(address stablecoin) {
        require(whitelist[stablecoin]);
        _;
    }

    function setRatio(uint256 _uniswapRatio, uint256 _aaveRatio) public onlyOwner {
        require(_uniswapRatio + _aaveRatio == 100);

        uint256 oldUniswapRatio = uniswapRatio;
        uint256 oldAaveRatio = aaveRatio;

        uniswapRatio = _uniswapRatio;
        aaveRatio = _aaveRatio;

        emit NewRatio(oldUniswapRatio, _uniswapRatio, oldAaveRatio, _aaveRatio);
    }

    function addStableCoin(address stableCoin) public onlyOwner {
        require(stableCoin != address(0));
        whitelist[stableCoin] = true;

        emit NewStabeleCoin(stableCoin);
    }

    function removeStableCoin(address stableCoin) public onlyOwner whitelisted(stableCoin) {
        whitelist[stableCoin] = false;

        emit StableCoinRemoved(stableCoin);
    }

    function deposit(address stableCoinIn, address stableCoinOut, uint256 amount) public whitelisted(stableCoinIn) whitelisted(stableCoinOut) {
        IERC20 token = IERC20(stableCoinIn);
        token.transferFrom(msg.sender, address(this), amount);

        uint256 amountToUniswap = (amount * uniswapRatio) / 100;
        uint256 amountToAave = (amount * aaveRatio) / 100;

        token.approve(address(uniswapV2Router), amountToUniswap);
        token.approve(address(aaveLendingPool), amountToAave);

        address[] memory path = new address[](2);
        path[0] = stableCoinIn;
        path[1] = stableCoinOut;

        uint256 minAmountOut = (amountToUniswap * 75) / 100;
        uint256 deadline = block.timestamp + 600;

        uniswapV2Router.swapExactTokensForTokens(
            amountToUniswap,
            minAmountOut,
            path,
            msg.sender,
            deadline
        );
        emit Swap(stableCoinIn, stableCoinOut, amountToUniswap);

        aaveLendingPool.supply(stableCoinIn, amountToAave, address(this), 0);
        deposits[stableCoinIn] += amountToAave;

        emit Supply(stableCoinIn, amountToAave);
    }

    function withdraw(address stableCoin, uint256 amount) public whitelisted(stableCoin) returns (uint256) {
        uint256 withdrawn = aaveLendingPool.withdraw(stableCoin, amount, msg.sender);
        deposits[stableCoin] -= withdrawn;

        emit Withdraw(stableCoin, withdrawn);
        return withdrawn;
    }

    function getAggregatedYield(address stableCoin) public whitelisted(stableCoin) view returns (uint256) {
        DataTypes.ReserveData memory reservedData = aaveLendingPool.getReserveData(stableCoin);
        uint256 totalDeposit = deposits[stableCoin];

        return totalDeposit * reservedData.currentLiquidityRate;
    }
}