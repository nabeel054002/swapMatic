//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//AMF = Autonomous mutual fund, the name doesnt exactly represent it, but sounds cool
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./WMATIC.sol";

contract swapMatic is ERC20Burnable, Ownable{

    ISwapRouter public immutable swapRouter;

    event swapsImplemented(address swapper, uint256 quantity, uint256 timestamp);

    uint24 public constant poolFee = 3000;
    //Fund token is tracks the ownership in this dao, and CT is the one which we wanna invest in
    constructor(ISwapRouter _swapRouter) ERC20("FundToken","FD"){
        //periodicity type interval
        swapRouter = _swapRouter;
    }

//0.02 == 20000000000000000
    function swapExactInputMatic(address tokenOut) payable public returns(uint256 amountOut){
        //since it is only used by this, instead of msg.value, how about taking it from matic balance of this smart contract  
        address payable WMATICaddress=payable(0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889);
        WMATIC wmat = WMATIC(WMATICaddress);

        wmat.deposit{value:msg.value}();

        wmat.transferFrom(msg.sender, address(this), msg.value);

        // Approve the router to spend DAI.
        wmat.approve(address(swapRouter), msg.value);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: WMATICaddress,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: msg.value,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
//0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa == WETH
        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);

        emit swapsImplemented(msg.sender, msg.value, block.timestamp);
        //to test this
    }
    //2 more functions
    receive() external payable {}

    fallback() external {}
}
