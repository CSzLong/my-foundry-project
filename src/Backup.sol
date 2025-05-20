// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MangaNFT is ERC1155, ERC1155Supply, Ownable {
    uint256 private _tokenIdCounter;

    address public platformAddress;
    IERC20 public paymentToken;
    uint256 public mintTimeout = 5 minutes;
    
    /*
    struct MangaChapter {
        string mangaTitle;
        string chapterTitle;
        string description;
        string language;
        uint256 seriesId;
        uint256 chapterNumber;
        uint256 publishTime;
        uint256 mintTime;
        uint256 maxCopies;
        address creator;
        string uri;
        string copyright;
        uint256 price;
        bool isFinal;
    }*/
    
    struct MangaChapter {
        string mangaTitle;
        string chapterTitle;
        string description;
        string language;
        uint256 seriesId;
        uint256 chapterNumber;
        uint256 publishTime;
        uint256 mintTime;
        uint256 maxCopies;
        address creator;
        string uri;
    }

    struct PendingPayment {
        uint256 tokenId;
        uint256 timestamp;
        uint256 amount;
        bool minted;
    }

    mapping(uint256 => MangaChapter) public mangaChapters;
    mapping(address => PendingPayment[]) public payments;

    event ChapterCreated(uint256 indexed tokenId, address indexed creator, string mangaTitle);
    event PaymentReceived(address indexed buyer, uint256 indexed tokenId, uint256 amount);
    event ChapterMinted(uint256 indexed tokenId, address indexed to, uint256 mintTime);
    event RefundIssued(address indexed buyer, uint256 indexed tokenId, uint256 amount);
    event BatchMinted(address[] recipients, uint256[] tokenIds);
    //event ChapterFinalFlagUpdated(uint256 indexed tokenId, bool isFinal);
    //event ChapterPriceUpdated(uint256 indexed tokenId, uint256 newPrice);
    event ChapterTitleUpdated(uint256 indexed tokenId, string newTitle);
    event MangaTitleUpdated(uint256 indexed tokenId, string newTitle);
    event ChapterDescriptionUpdated(uint256 indexed tokenId, string newDescription);
    event PlatformAddressUpdated(address indexed oldAddress, address indexed newAddress);
    event PaymentTokenUpdated(address indexed oldToken, address indexed newToken);

    modifier onlyPlatform() {
        require(msg.sender == platformAddress, "Only platform can mint");
        _;
    }

    constructor(string memory _uri, address _platformAddress, address _paymentToken)
        ERC1155(_uri)
        Ownable(msg.sender)
    {
        require(_platformAddress != address(0), "Invalid platform address");
        require(_paymentToken != address(0), "Invalid token address");
        platformAddress = _platformAddress;
        paymentToken = IERC20(_paymentToken);
    }
    
    function createChapter(
        string memory mangaTitle,
        string memory chapterTitle,
        string memory description,
        string memory language,
        uint256 seriesId,
        uint256 chapterNumber,
        uint256 publishTime,
        uint256 maxCopies,
        string memory uri_
    ) external returns (uint256) {
        _tokenIdCounter++;
        uint256 newTokenId = _tokenIdCounter;
        
        mangaChapters[newTokenId] = MangaChapter({
            mangaTitle: mangaTitle,
            chapterTitle: chapterTitle,
            description: description,
            language: language,
            seriesId: seriesId,
            chapterNumber: chapterNumber,
            publishTime: publishTime,
            mintTime:0,
            maxCopies: maxCopies,
            creator: msg.sender,
            uri: uri_
        });

        emit ChapterCreated(newTokenId, msg.sender, mangaTitle);
        return newTokenId;
    }

    /*
    function createChapter(
        string memory mangaTitle,
        string memory chapterTitle,
        string memory description,
        string memory language,
        uint256 seriesId,
        uint256 chapterNumber,
        uint256 publishTime,
        uint256 maxCopies,
        string memory uri_,
        string memory copyright,
        uint256 price,
        bool isFinal
    ) external returns (uint256) {
        _tokenIdCounter++;
        uint256 newTokenId = _tokenIdCounter;

        mangaChapters[newTokenId] = MangaChapter({
            mangaTitle: mangaTitle,
            chapterTitle: chapterTitle,
            description: description,
            language: language,
            seriesId: seriesId,
            chapterNumber: chapterNumber,
            publishTime: publishTime,
            mintTime: 0,
            maxCopies: maxCopies,
            creator: msg.sender,
            uri: uri_,
            copyright: copyright,
            price: price,
            isFinal: isFinal
        });

        emit ChapterCreated(newTokenId, msg.sender, mangaTitle);
        return newTokenId;
    }
    */
    
    /*
    function payForChapter(uint256 tokenId) external {
        MangaChapter storage chapter = mangaChapters[tokenId];
        require(chapter.price > 0, "Chapter is not for sale");
        
        require(paymentToken.transferFrom(msg.sender, platformAddress, chapter.price), "Payment failed");

        payments[msg.sender].push(PendingPayment({
            tokenId: tokenId,
            timestamp: block.timestamp,
            amount: chapter.price,
            minted: false
        }));

        emit PaymentReceived(msg.sender, tokenId, chapter.price);
    }

    function mintChapter(address to, uint256 tokenId) public onlyPlatform {
        require(to != address(0), "Invalid recipient");

        MangaChapter storage chapter = mangaChapters[tokenId];
        require(totalSupply(tokenId) < chapter.maxCopies, "No more copies");

        bool found = false;
        PendingPayment[] storage userPayments = payments[to];

        for (uint i = 0; i < userPayments.length; i++) {
            if (
                userPayments[i].tokenId == tokenId &&
                !userPayments[i].minted &&
                block.timestamp <= userPayments[i].timestamp + mintTimeout
            ) {
                userPayments[i].minted = true;
                found = true;
                break;
            }
        }

        require(found, "No valid payment found");

        chapter.mintTime = block.timestamp;
        _mint(to, tokenId, 1, "");

        emit ChapterMinted(tokenId, to, block.timestamp);
    }
    
    function refundIfExpired(address buyer, uint256 tokenId) external {
        PendingPayment[] storage userPayments = payments[buyer];
        for (uint i = 0; i < userPayments.length; i++) {
            PendingPayment storage p = userPayments[i];
            if (
                p.tokenId == tokenId &&
                !p.minted &&
                block.timestamp > p.timestamp + mintTimeout
            ) {
                uint256 refundAmount = p.amount;
                p.amount = 0;
                p.minted = true;

                require(paymentToken.transfer(buyer, refundAmount), "Refund failed");
                emit RefundIssued(buyer, tokenId, refundAmount);
                break;
            }
        }
    }

    function batchMintChapter(address[] calldata recipients, uint256[] calldata tokenIds) external onlyPlatform {
        require(recipients.length == tokenIds.length, "Array length mismatch");
        for (uint i = 0; i < recipients.length; i++) {
            mintChapter(recipients[i], tokenIds[i]);
        }
        emit BatchMinted(recipients, tokenIds);
    }
    */
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal override(ERC1155, ERC1155Supply) {
        // 根据你的需求自定义逻辑
        super._update(from, to, ids, values); // 调用合适的父类函数
    }

    function freeMint(address to, uint256 tokenId) public onlyPlatform {
        require(to != address(0), "Invalid recipient");

        MangaChapter storage chapter = mangaChapters[tokenId];
        require(totalSupply(tokenId) < chapter.maxCopies, "No more copies");
        
        chapter.mintTime = block.timestamp;
        _mint(to, tokenId, 1, "");
        
        emit ChapterMinted(tokenId, to, block.timestamp);
    }
    
    function getChapterInfo(uint256 tokenId) external view returns (MangaChapter memory) {
        return mangaChapters[tokenId];
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return mangaChapters[tokenId].uri;
    }

    function updatePlatformAddress(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Invalid address");
        address oldAddress = platformAddress;
        platformAddress = newAddress;
        emit PlatformAddressUpdated(oldAddress, newAddress);
    }

    function updatePaymentToken(address newToken) external onlyOwner {
        require(newToken != address(0), "Invalid token address");
        address oldToken = address(paymentToken);
        paymentToken = IERC20(newToken);
        emit PaymentTokenUpdated(oldToken, newToken);
    }
    
    /*
    function updateIsFinal(uint256 tokenId, bool newIsFinal) external {
        MangaChapter storage chapter = mangaChapters[tokenId];
        require(msg.sender == chapter.creator || msg.sender == owner(), "Not authorized");
        chapter.isFinal = newIsFinal;
        emit ChapterFinalFlagUpdated(tokenId, newIsFinal);
    }

    function updatePrice(uint256 tokenId, uint256 newPrice) external {
        MangaChapter storage chapter = mangaChapters[tokenId];
        require(msg.sender == chapter.creator || msg.sender == owner(), "Not authorized");
        chapter.price = newPrice;
        emit ChapterPriceUpdated(tokenId, newPrice);
    }*/

    function updateChapterTitle(uint256 tokenId, string calldata newTitle) external {
        MangaChapter storage chapter = mangaChapters[tokenId];
        require(msg.sender == chapter.creator || msg.sender == owner(), "Not authorized");
        chapter.chapterTitle = newTitle;
        emit ChapterTitleUpdated(tokenId, newTitle);
    }

    function updateMangaTitle(uint256 tokenId, string calldata newTitle) external {
        MangaChapter storage chapter = mangaChapters[tokenId];
        require(msg.sender == chapter.creator || msg.sender == owner(), "Not authorized");
        chapter.mangaTitle = newTitle;
        emit MangaTitleUpdated(tokenId, newTitle);
    }

    function updateDescription(uint256 tokenId, string calldata newDescription) external {
        MangaChapter storage chapter = mangaChapters[tokenId];
        require(msg.sender == chapter.creator || msg.sender == owner(), "Not authorized");
        chapter.description = newDescription;
        emit ChapterDescriptionUpdated(tokenId, newDescription);
    }
    
}