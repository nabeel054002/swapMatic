const {ethers, BigNumber, Contract, utils} = require("ethers");
require('dotenv').config("../.env")
const MUMBAI_PROVIDER=new ethers.providers.JsonRpcProvider(process.env.QUICKNODE_HTTP_URL);
const WALLET_ADDRESS = process.env.WALLET_ADDRESS;
const WALLET_PRIVATE_KEY=process.env.PRIVATE_KEY;
const {MATICSWAP_ABI, MATICSWAP_ADDRESS} = require("../constants/index");

const wallet = new ethers.Wallet(WALLET_PRIVATE_KEY);
const connectedWallet = wallet.connect(MUMBAI_PROVIDER);

async function main(){
    const swapsContract = new ethers.Contract(MATICSWAP_ADDRESS, MATICSWAP_ABI, MUMBAI_PROVIDER);
    const connectedContract = await swapsContract.connect(connectedWallet);
    const tx = await connectedContract.swapExactInputMatic("0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa", {value: "10000000000000000"});
    await tx.wait();
}
main();