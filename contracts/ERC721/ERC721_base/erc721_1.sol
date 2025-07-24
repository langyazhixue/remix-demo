// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
interface IERC165 {
    // 检查合约是否支持某个接口
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721 is IERC165 {
    
    // 获取某个用户的余额
    function balanceOf(address owner) external view returns (uint256 balance);
    
    // 通过tokenId获取某个token的拥有者
    function ownerOf(uint256 tokenId) external view returns (address owner);
    
    // 转移token
    function safeTransferFrom(address from, address to, uint256 tokenId)
        external;
    
    // 安全转移token，附带额外数据
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    
    // 授权者转移Token
    function transferFrom(address from, address to, uint256 tokenId) external;
    
    // 授权某个地址可以操作tokenId
    function approve(address to, uint256 tokenId) external;

    // 获取tokenId的授权地址
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);
    // 授权某个地址可以操作所有token
    function setApprovalForAll(address operator, bool _approved) external;
    // 查询某个地址是否被授权可以操作所有token
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

interface IERC721Receiver {
    // 接收ERC721代币时调用的函数
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721 is IERC721 {
    event Transfer(
        address indexed from, address indexed to, uint256 indexed id
    );
    event Approval(
        address indexed owner, address indexed spender, uint256 indexed id
    );
    event ApprovalForAll(
        address indexed owner, address indexed operator, bool approved
    );

    // Mapping from token ID to owner address
    // 存储每个tokenId对应的拥有者地址
    mapping(uint256 => address) internal _ownerOf;

    // Mapping owner address to token count
    // 
    // 存储每个地址拥有的token数量
    mapping(address => uint256) internal _balanceOf;

    // Mapping from token ID to approved address
    // 存储每个tokenId被授权的地址
    mapping(uint256 => address) internal _approvals;

    // Mapping from owner to operator approvals
    // 存储每个地址对其他地址的授权信息,返回某个地址是否授权 另外一个地址可以操作他的所有NFT。。。
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    
    // 检查合约是否支持某个接口
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        returns (bool)
    {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC165).interfaceId;
    }

    // 返回某个tokenId的拥有者地址
    function ownerOf(uint256 id) external view returns (address owner) {
        owner = _ownerOf[id];
        require(owner != address(0), "token doesn't exist");
    }
    // 返回某个地址拥有的token数量
    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "owner = zero address");
        return _balanceOf[owner];
    }
    // 获取某个tokenId的授权地址
    function getApproved(uint256 id) external view returns (address) {
        require(_ownerOf[id] != address(0), "token doesn't exist");
        return _approvals[id];
    }

    // 检查某个地址是否被授权可以操作某个tokenId
    function _isApprovedOrOwner(address owner, address spender, uint256 id)
        internal
        view
        returns (bool)
    {
        return (
            spender == owner || isApprovedForAll[owner][spender]
                || spender == _approvals[id]
        );
    }


    // 返回某个地址是否被授权可以操作所有token
    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // 检查某个地址是否被授权可以操作所有token
    function approve(address spender, uint256 id) external {
        address owner = _ownerOf[id];
        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "not authorized"
        );
        _approvals[id] = spender;
        emit Approval(owner, spender, id);
    }
    
    // 转移token
    function transferFrom(address from, address to, uint256 id) public {
        require(from == _ownerOf[id], "from != owner");
        require(to != address(0), "transfer to zero address");

        require(_isApprovedOrOwner(from, msg.sender, id), "not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;

        delete _approvals[id];

        emit Transfer(from, to, id);
    }
    // 安全转移token，附带额外数据
    function safeTransferFrom(address from, address to, uint256 id) external {
        transferFrom(from, to, id);
        require(
            to.code.length == 0
                || IERC721Receiver(to).onERC721Received(msg.sender, from, id, "")
                    == IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }
    // 安全转移token，附带额外数据
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) external {
        transferFrom(from, to, id);

        require(
            to.code.length == 0
                || IERC721Receiver(to).onERC721Received(msg.sender, from, id, data)
                    == IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    // 内部函数：铸造NFT
    function _mint(address to, uint256 id) internal {
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");

        _balanceOf[to]++;
        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }
    // 内部函数：销毁NFT
    function _burn(uint256 id) internal {
        address owner = _ownerOf[id];
        require(owner != address(0), "not minted");

        _balanceOf[owner] -= 1;

        delete _ownerOf[id];
        delete _approvals[id];

        emit Transfer(owner, address(0), id);
    }
}

contract MyNFT is ERC721 {
    function mint(address to, uint256 id) external {
        _mint(to, id);
    }

    function burn(uint256 id) external {
        require(msg.sender == _ownerOf[id], "not owner");
        _burn(id);
    }
}

//  0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 给  1 2 3 4 NFT
//   0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 给  5 6 7 8 NFT 授权给  0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB 转所有币


// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 授权 1  
//  0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 转 1  到 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
//  0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB 转账 2

//  0x5B38Da6a701c568545dCfcB03FcB875f56beddC4  safeTransferFrom 4 gei 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB