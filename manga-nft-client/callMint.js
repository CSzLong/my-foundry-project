// mint.js

import { ethers } from "ethers";
import * as dotenv from "dotenv";
dotenv.config();

async function main() {
  // 定义 ABI（只包含我们要用的函数）
  const abi = [
    "function freeMint(address to, uint256 tokenId) public"
  ];

  // 创建 provider
  const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);

  // 用平台的钱包私钥初始化 signer
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

  // 指定合约地址
  const contract = new ethers.Contract(process.env.MANGA_NFT_ADDRESS, abi, wallet);
  
  // 要 mint 给谁（可以改成你要测试的钱包地址）
  const toAddress = "0xdbe41aFD9e285b446735Ca523C53a01Ad98e78C9";
  
  // 要 mint 的 tokenId
  const tokenId = "1749001780000001";
  
  // 发起交易
  console.log(`正在 mint tokenId = ${tokenId} 给 ${toAddress}...`);
  const tx = await contract.freeMint(toAddress, tokenId);
  await tx.wait();
  console.log("✅ Mint 成功！");
}

main().catch((err) => {
  console.error("❌ Mint 失败：", err);
});
