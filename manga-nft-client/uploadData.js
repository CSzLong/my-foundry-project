import dotenv from "dotenv";
dotenv.config();
import { ethers } from "ethers";

// 合约地址和 ABI
const abi = [
    "function uploadCreatorData(uint256 monthId, address user, tuple(uint256 totalNFTPublished, uint256 totalNFTShared, uint256 totalNFTValue, uint256 totalTransactions) data) external",
    "function uploadReaderData(uint256 monthId, address user, tuple(uint256 tokensChargedThisMonth, uint256 currentBalance) data) external"
  ];
  
// 初始化 provider 和 signer
const RPC_URL = process.env.RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const contractAddress = process.env.UPLOADER_ADDR;

const provider = new ethers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
const contract = new ethers.Contract(contractAddress, abi, wallet);

async function main() {
  const monthId = 202405;

  const creatorAddr = "0x1E86A3da7301AC98DD170278E2c5cF9D6d9616C7";
  const readerAddr = "0x9d7D6b191255919A608027F138B577bE8b701509";

  const creatorData = {
    totalNFTPublished: 12,
    totalNFTShared: 30,
    totalNFTValue: 4800,
    totalTransactions: 15
  };
  
  const readerData = {
    tokensChargedThisMonth: 200,
    currentBalance: 50
  };

  try {
    const tx1 = await contract.uploadCreatorData(monthId, creatorAddr, creatorData);
    await tx1.wait();
    console.log("✅ Creator data uploaded:", tx1.hash);

    const tx2 = await contract.uploadReaderData(monthId, readerAddr, readerData);
    await tx2.wait();
    console.log("✅ Reader data uploaded:", tx2.hash);
  } catch (err) {
    console.error("❌ Upload failed:", err);
  }
}

main();
