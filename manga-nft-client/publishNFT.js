import dotenv from "dotenv";
dotenv.config();
import { ethers } from "ethers";

async function main() {
  const RPC_URL = process.env.RPC_URL;
  const PRIVATE_KEY = process.env.PRIVATE_KEY;
  const MANGA_NFT_ADDRESS = process.env.MANGA_NFT_ADDRESS;

  if (!RPC_URL || !PRIVATE_KEY || !MANGA_NFT_ADDRESS) {
    console.error("请确认 .env 文件中已正确设置 RPC_URL、PRIVATE_KEY 和 MANGA_NFT_ADDRESS");
    process.exit(1);
  }

  const abi = [
    "function createChapter(string mangaTitle,string description,string language,uint256 publishTime,uint256 maxCopies, uint256 maxPerUser, string uri) external returns (uint256)",
    "event ChapterCreated(uint256 indexed tokenId, address indexed creator, string mangaTitle)"
  ];

  const provider = new ethers.JsonRpcProvider(RPC_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
  const contract = new ethers.Contract(MANGA_NFT_ADDRESS, abi, wallet);

  const tx = await contract.createChapter(
    "火影忍者",
    "多重影分身",
    "CN",
    Math.floor(new Date("2025-05-15").getTime() / 1000),
    5,
    2,
    "https://gateway.pinata.cloud/ipfs/bafkreihepqt2p3szkcjfwiipmtgsgmyoz6vtpxiulcc3agv4zw6ezkfhvq"
  );

  console.log("交易已发送，交易哈希:", tx.hash);

  const receipt = await tx.wait();
  console.log("交易确认，区块号:", receipt.blockNumber);
  
  // 解析事件
  const iface = new ethers.Interface(abi);
  for (const log of receipt.logs) {
    try {
      const parsedLog = iface.parseLog(log);
      if (parsedLog.name === "ChapterCreated") {
        const { tokenId, creator, mangaTitle } = parsedLog.args;

        console.log("🎉 事件 ChapterCreated:");
        console.log("  🔸 tokenId:    ", tokenId.toString());
        console.log("  🔸 creator:    ", creator);
        console.log("  🔸 mangaTitle: ", mangaTitle);
        
        return;
      }
    } catch (err) {
      // 忽略非目标事件
    }
  }

  console.log("⚠️ 没有找到 ChapterCreated 事件");
}

main().catch((error) => {
  console.error("执行出错:", error);
  process.exit(1);
});
