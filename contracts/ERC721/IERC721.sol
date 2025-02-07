// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC165} from "../ERC165/ERC165.sol";

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed spender, uint256 indexed tokenId);
    
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function ownerOf(uint256 tokenId) external view returns(address);

    function balanceOf(address owner) external view returns(uint256);

    function getApproved(uint256 tokenId) external view returns(address);

    function isApprovedForAll(address owner, address operator) external view returns(bool);

    function approve(
        address spender,
        uint256 tokenId
    ) external;

    function setApprovalForAll(
        address operator,
        bool approved
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}