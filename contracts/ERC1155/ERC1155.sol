// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC1155} from "./IERC1155.sol";
import {IERC1155MetadataURI} from "./extensions/IERC1155MetadataURI.sol";
import {IERC1155Receiver} from "./IERC1155Receiver.sol";
import {IERC165, ERC165} from "../ERC165/ERC165.sol";

import {ERC1155Utils} from "./utils/ERC1155Utils.sol";

abstract contract ERC1155 is ERC165, IERC1155, IERC1155MetadataURI {
    mapping(address owner => mapping(uint256 id => uint256)) public balanceOf;
    mapping(address owner => mapping(address operator => bool)) public isApprovedForAll;

    string private _uri;

    // -------------------------------

    constructor(string memory uri_) {
       _setURI(uri_);
    }

    // -------------------------------
    // METADATA LOGIC

    function _setURI(string memory newUri) internal virtual {
        _uri = newUri;
    }

    function uri(uint256 /* id */) external view virtual returns(string memory) {
        return _uri;
    }

    // -------------------------------
    // ERC1155 LOGIC

    function balanceOfBatch(
        address[] calldata owners,
        uint256[] calldata ids
    ) public view virtual returns(uint256[] memory balances) {
        require(owners.length == ids.length, "Length mismatch");

        balances = new uint256[](owners.length);

        unchecked {
            for (uint256 i = 0; i < owners.length; ++i) {
                balances[i] = balanceOf[owners[i]][ids[i]];
            }
        }
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public virtual {
        require(msg.sender == from || isApprovedForAll[from][msg.sender], "Not approved or owner!");
        require(to != address(0), "to cannot be zero address!");

        balanceOf[from][id] -= amount;
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);

        require(ERC1155Utils.checkOnERC1155Received(msg.sender, from, to, id, amount, data), "Transfer to non-erc1155 receiver!");
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public virtual {
        require(ids.length == amounts.length, "Length mismatch");
        require(msg.sender == from || isApprovedForAll[from][msg.sender], "Not approved or owner!");

        uint256 id;
        uint256 amount;

        for (uint256 i = 0; i < ids.length; ) {
            id = ids[i];
            amount = amounts[i];

            balanceOf[from][id] -= amount;
            balanceOf[to][id] += amount;

            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        require(ERC1155Utils.checkOnERC1155BatchReceived(msg.sender, from, to, ids, amounts, data), "Transfer to non-erc1155 receiver!");
    }

    // -------------------------------
    // ERC165 LOGIC

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns(bool) {
        return 
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // -------------------------------
    // MINT/BURN LOGIC

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, address(0), to, id, amount);

        require(ERC1155Utils.checkOnERC1155Received(msg.sender, address(0), to, id, amount, data), "Transfer to non-erc1155 receiver!");
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "Length mismatch");

        for (uint256 i = 0; i < ids.length; ) {
            balanceOf[to][ids[i]] += amounts[i];

            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        require(ERC1155Utils.checkOnERC1155BatchReceived(msg.sender, address(0), to, ids, amounts, data), "Transfer to non-erc1155 receiver!");
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        balanceOf[from][id] -= amount;

        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }

    function _batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(ids.length == amounts.length, "Length mismatch");

        for (uint256 i = 0; i < ids.length; ) {
            balanceOf[from][ids[i]] -= amounts[i];

            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, address(0), ids, amounts);
    }
}