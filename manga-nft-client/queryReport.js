import dotenv from "dotenv";
dotenv.config();
import { ethers } from "ethers";

// 只需要读取的 ABI 片段
const abi = [
  "function getCreatorData(uint256,address) view returns (tuple(uint256 totalNFTPublished, uint256 totalNFTShared, uint256 totalNFTValue, uint256 totalTransactions))",
  "function getReaderData(uint256,address) view returns (tuple(uint256 tokensChargedThisMonth, uint256 currentBalance))"
];

// 合约地址 & provider 初始化
const contractAddress = process.env.UPLOADER_ADDR;
const RPC_URL = process.env.RPC_URL;

const provider = new ethers.JsonRpcProvider(RPC_URL);
const contract = new ethers.Contract(contractAddress, abi, provider);

async function main() {
  const monthId = 202501;
  
  const creatorAddr = "0xC001000000000000000000000000000000000001";
  const readerAddr = "0xC002000000000000000000000000000000000001";
  
  try {
    const creatorData = await contract.getCreatorData(monthId, creatorAddr);
    console.log("📊 Creator Data:");
    console.log(`- totalNFTPublished: ${creatorData.totalNFTPublished}`);
    console.log(`- totalNFTShared: ${creatorData.totalNFTShared}`);
    console.log(`- totalNFTValue: ${creatorData.totalNFTValue}`);
    console.log(`- totalTransactions: ${creatorData.totalTransactions}`);

    const readerData = await contract.getReaderData(monthId, readerAddr);
    console.log("\n📚 Reader Data:");
    console.log(`- tokensChargedThisMonth: ${readerData.tokensChargedThisMonth}`);
    console.log(`- currentBalance: ${readerData.currentBalance}`);
  } catch (err) {
    console.error("❌ Query failed:", err);
  }
}

main();
