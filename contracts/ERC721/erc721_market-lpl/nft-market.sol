// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "@openzeppelin/contracts/interfaces/IERC721.sol";

import "@openzeppelin/contracts/interfaces/IERC20.sol";
/**
 * @title NFTMarket contract that allows atomic swaps of ERC20 and ERC721
 */
contract Market is IERC721Receiver {
    IERC20 public erc20;
    IERC721 public erc721;

    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    struct Order {
        address seller; // 卖方是谁
        uint256 tokenId; // tokenId 是几
        uint256 price; // 价格多少
    }

    mapping(uint256 => Order) public orderOfId; // token id to order 根据 tokenId 去查订单
    Order[] public orders; // all orders
    
    // 通过 tokenId 找到订单索引
    mapping(uint256 => uint256) public idToOrderIndex; // token id to order index

    // 交易事件
    event Deal(address buyer, address seller, uint256 tokenId, uint256 price);

    // 新订单事件
    event NewOrder(address seller, uint256 tokenId, uint256 price);

    // 取消订单事件
    event CancelOrder(address seller, uint256 tokenId);
    // 修改价格事件
    event ChangePrice(
        address seller,
        uint256 tokenId,
        uint256 previousPrice,
        uint256 price
    );
    // 合约构造函数，传入 ERC20 和 ERC721 合约地址
    constructor(IERC20 _erc20, IERC721 _erc721) {
        require(
            address(_erc20) != address(0),
            "Market: IERC20 contract address must be non-null"
        );
        require(
            address(_erc721) != address(0),
            "Market: IERC721 contract address must be non-null"
        );
        erc20 = _erc20;
        erc721 = _erc721;
    }

    // 购买，从买家转币给卖家，从交易市场转NFT给买家
    // 买家需要先 approve 交易市场合约
    function buy(uint256 _tokenId) external {
        require(isListed(_tokenId), "Market: Token ID is not listed");

        address seller = orderOfId[_tokenId].seller;
        address buyer = msg.sender;
        uint256 price = orderOfId[_tokenId].price;

        require(
            erc20.transferFrom(buyer, seller, price),
            "Market: ERC20 transfer not successful"
        );
        // 从交易市场合约转NFT给买家
        erc721.safeTransferFrom(address(this), buyer, _tokenId);
        removeListing(_tokenId);
        emit Deal(buyer, seller, _tokenId, price);
    }

    // 取消订单，把NFT 转回卖家
    // 取消订单后，NFT 不在市场上
    function cancelOrder(uint256 _tokenId) external {
        require(isListed(_tokenId), "Market: Token ID is not listed");

        address seller = orderOfId[_tokenId].seller;
        require(seller == msg.sender, "Market: Sender is not seller");

        erc721.safeTransferFrom(address(this), seller, _tokenId);
        removeListing(_tokenId);

        emit CancelOrder(seller, _tokenId);
    }

    function changePrice(uint256 _tokenId, uint256 _price) external {
        require(isListed(_tokenId), "Market: Token ID is not listed");
        address seller = orderOfId[_tokenId].seller;
        // 确保调用者是卖家，只有卖家能改价格
        require(seller == msg.sender, "Market: Sender is not seller");
        
        require(_price > 0, "Market: Price must be greater than zero");
        uint256 previousPrice = orderOfId[_tokenId].price;
        orderOfId[_tokenId].price = _price;
        Order storage order = orders[idToOrderIndex[_tokenId]];
        order.price = _price;
        emit ChangePrice(seller, _tokenId, previousPrice, _price);
    }
    // 获取所有 NFT 订单
    function getAllNFTs() public view returns (Order[] memory) {
        return orders;
    }

    // 获取我的 NFT 订单
    // 只返回卖家是当前调用者的订单
    function getMyNFTs() public view returns (Order[] memory) {
        Order[] memory myOrders = new Order[](orders.length);
        uint256 myOrdersCount = 0;

        for (uint256 i = 0; i < orders.length; i++) {
            if (orders[i].seller == msg.sender) {
                myOrders[myOrdersCount] = orders[i];
                myOrdersCount++;
            }
        }

        Order[] memory myOrdersTrimmed = new Order[](myOrdersCount);
        for (uint256 i = 0; i < myOrdersCount; i++) {
            myOrdersTrimmed[i] = myOrders[i];
        }

        return myOrdersTrimmed;
    }
    // 检查某个 tokenId 是否在市场上
    function isListed(uint256 _tokenId) public view returns (bool) {
        return orderOfId[_tokenId].seller != address(0);
    }

    function getOrderLength() public view returns (uint256) {
        return orders.length;
    }

    /**
     * @dev List a good using a ERC721 receiver hook
     * @param _operator the caller of this function
     * @param _seller the good seller
     * @param _tokenId the good id to list
     * @param _data contains the pricing data as the first 32 bytes
     */
    function onERC721Received(
        address _operator,
        address _seller,
        uint256 _tokenId,
        bytes calldata _data
    ) public override returns (bytes4) {
        require(_operator == _seller, "Market: Seller must be operator");
        uint256 _price = toUint256(_data, 0);
        // 用户把币转给 合约时候，合约把币上架
        placeOrder(_seller, _tokenId, _price);
        return MAGIC_ON_ERC721_RECEIVED;
    }

    // https://stackoverflow.com/questions/63252057/how-to-use-bytestouint-function-in-solidity-the-one-with-assembly
    // 将 bytes 转换为 uint256
    // _bytes: 要转换的字节数组
    function toUint256(
        bytes memory _bytes,
        uint256 _start
    ) public pure returns (uint256) {
        require(_start + 32 >= _start, "Market: toUint256_overflow");
        require(_bytes.length >= _start + 32, "Market: toUint256_outOfBounds");
        uint256 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }
        return tempUint;
    }

    // NFT 上架
    function placeOrder(
        address _seller,
        uint256 _tokenId,
        uint256 _price
    ) internal {
        require(_price > 0, "Market: Price must be greater than zero");

        orderOfId[_tokenId].seller = _seller; // 通过 _tokenId 查 order
        orderOfId[_tokenId].price = _price;
        orderOfId[_tokenId].tokenId = _tokenId;
        orders.push(orderOfId[_tokenId]); // orders 订单列表增加 order
        idToOrderIndex[_tokenId] = orders.length - 1; // 通过tokenId 查  orders 中的index 
        emit NewOrder(_seller, _tokenId, _price);
    }

    // 删除订单
    function removeListing(uint256 _tokenId) internal {
        delete orderOfId[_tokenId];

        uint256 orderToRemoveIndex = idToOrderIndex[_tokenId];
        uint256 lastOrderIndex = orders.length - 1;

        if (lastOrderIndex != orderToRemoveIndex) {
            Order memory lastOrder = orders[lastOrderIndex];
            orders[orderToRemoveIndex] = lastOrder;
            idToOrderIndex[lastOrder.tokenId] = orderToRemoveIndex;
        }

        orders.pop();
    }
}


// 操作流程（此交易市场的主要功能 1.NFT上架 2. NFT交易 3. NFT修改价格 4. NFT下架）
// 第一步：部署ERC20-usdt.sol, 以及 erc721-nft.sol
// 第二步：部署 nft-market.sol（通过传入ERC20-usdt合约地址以及erc721-nft合约地址）
// 第三步：在erc721-nft 这个合约转一个nft给 nft-market 合约，自动调用 nft-market的 onERC721Received 函数，
// 实现nft 在交易市场的自动上架
// 第四步： 在交易市场价格修改
// 第五步：在交易市场交易
// 第六步：在交易市场的产品下架