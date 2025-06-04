import dotenv from "dotenv";
dotenv.config();
import { ethers } from "ethers";

const abi = [
  "function batchUploadCreatorData(uint256,address[],(uint256,uint256,uint256,uint256)[]) external",
  "function batchUploadReaderData(uint256,address[],(uint256,uint256)[]) external"
];

const contractAddress = process.env.UPLOADER_ADDR;
const RPC_URL = process.env.RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

const provider = new ethers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
const contract = new ethers.Contract(contractAddress, abi, wallet);

async function main() {
  const monthId = 202502;

  const creatorAddresses = Array.from({ length: 10 }, (_, i) =>
    `0xC00100000000000000000000000000000000000${(i + 1).toString(16).toUpperCase()}`
  );

  // 改为 tuple 格式（数组形式）
  const creatorDataList = [
    [10, 25, 4000, 14],
    [8, 20, 3100, 10],
    [15, 35, 5200, 18],
    [12, 28, 4600, 16],
    [6, 12, 2100, 7],
    [20, 40, 8500, 25],
    [13, 27, 4800, 17],
    [9, 18, 3000, 12],
    [17, 33, 6900, 21],
    [5, 10, 1600, 6]
  ];

  const readerAddresses = Array.from({ length: 10 }, (_, i) =>
    `0xC00200000000000000000000000000000000000${(i + 1).toString(16).toUpperCase()}`
  );

  const readerDataList = [
    [200, 50],
    [150, 40],
    [100, 30],
    [80, 20],
    [300, 60],
    [250, 70],
    [120, 35],
    [400, 90],
    [350, 80],
    [180, 45]
  ];

  try {
    const tx1 = await contract.batchUploadCreatorData(monthId, creatorAddresses, creatorDataList);
    await tx1.wait();
    console.log("✅ 10 Creator 数据已上传:", tx1.hash);

    const tx2 = await contract.batchUploadReaderData(monthId, readerAddresses, readerDataList);
    await tx2.wait();
    console.log("✅ 10 Reader 数据已上传:", tx2.hash);
  } catch (err) {
    console.error("❌ 上传失败:", err);
  }
}

main();
