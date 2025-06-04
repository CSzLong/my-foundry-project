import dotenv from "dotenv";
dotenv.config();
import { ethers } from "ethers";

async function main() {
  const RPC_URL = process.env.RPC_URL;
  const PRIVATE_KEY = process.env.CREATOR_KEY;
  const MANGA_NFT_ADDRESS = process.env.MANGA_NFT_ADDRESS;

  if (!RPC_URL || !PRIVATE_KEY || !MANGA_NFT_ADDRESS) {
    console.error("请确认 .env 文件中已正确设置 RPC_URL、PRIVATE_KEY 和 MANGA_NFT_ADDRESS");
    process.exit(1);
  }

  // 合约 ABI，函数和事件
  const abi = [
    `function createChapter(
      string mangaTitleZh,
      string mangaTitleEn,
      string mangaTitleJp,
      string descriptionZh,
      string descriptionEn,
      string descriptionJp,
      uint256 maxCopies,
      string uri_
    ) external returns (uint256)`,

    `event ChapterCreated(
      uint256 indexed tokenId,
      address indexed creator,
      string mangaTitleZh,
      string mangaTitleEn,
      string mangaTitleJp
    )`,

    `event ChapterMinted(
      uint256 indexed tokenId,
      address indexed to,
      uint256 mintTime
    )`
  ];

  // 连接 provider 和 signer
  const provider = new ethers.JsonRpcProvider(RPC_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
  const contract = new ethers.Contract(MANGA_NFT_ADDRESS, abi, wallet);

  console.log("准备调用 createChapter 方法...");

  // 调用 createChapter，注意 maxCopies 必须是5的倍数，这里用10
  const tx = await contract.createChapter(
    "海贼王 第一话 冒险的黎明",               // mangaTitleZh
    "One Piece Chapter 1: Dawn of the Adventure",               // mangaTitleEn
    "ワンピース 第1話 冒険の夜明け",                // mangaTitleJp
    "伟大的冒险开始了！路飞踏上旅程的第一步。",              // descriptionZh
    "The grand adventure begins! Luffy sets off on his journey.",  // descriptionEn
    "壮大な冒険が始まる！ルフィの旅の第一歩。",              // descriptionJp
    5,                     // maxCopies，必须是5的倍数
    "https://gateway.pinata.cloud/ipfs/bafkreihepqt2p3szkcjfwiipmtgsgmyoz6vtpxiulcc3agv4zw6ezkfhvq" // uri_
  );
  
  console.log("交易已发送，交易哈希:", tx.hash);

  const receipt = await tx.wait();
  console.log("交易已确认，区块号:", receipt.blockNumber);

  // 解析事件
  const iface = new ethers.Interface(abi);
  for (const log of receipt.logs) {
    try {
      const parsedLog = iface.parseLog(log);

      if (parsedLog.name === "ChapterCreated") {
        const { tokenId, creator, mangaTitleZh, mangaTitleEn, mangaTitleJp } = parsedLog.args;
        console.log("🎉 ChapterCreated 事件:");
        console.log("  🔸 tokenId:     ", tokenId.toString());
        console.log("  🔸 creator:     ", creator);
        console.log("  🔸 mangaTitleZh:", mangaTitleZh);
        console.log("  🔸 mangaTitleEn:", mangaTitleEn);
        console.log("  🔸 mangaTitleJp:", mangaTitleJp);
      }
      
      if (parsedLog.name === "ChapterMinted") {
        const { tokenId, to, mintTime } = parsedLog.args;
        console.log("🔔 ChapterMinted 事件:");
        console.log("  🔸 tokenId: ", tokenId.toString());
        console.log("  🔸 creator: ", to);
        console.log("  🔸 mintTime:", new Date(mintTime.toNumber() * 1000).toLocaleString());
      }
    } catch {
      // 忽略无效事件
    }
  }

  // 下面示范如何实时监听合约的 ChapterMinted 事件（可选）
  // contract.on("ChapterMinted", (tokenId, creator, mintTime, event) => {
  //   console.log("实时监听到 ChapterMinted 事件：");
  //   console.log("  tokenId:", tokenId.toString());
  //   console.log("  creator:", creator);
  //   console.log("  mintTime:", new Date(mintTime.toNumber() * 1000).toLocaleString());
  // });
}

main().catch((error) => {
  console.error("执行出错:", error);
  process.exit(1);
});
