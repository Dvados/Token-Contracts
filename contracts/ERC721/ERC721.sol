// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC721} from "./IERC721.sol";
import {IERC721Metadata} from "./extensions/IERC721Metadata.sol";
import {IERC721Receiver} from "./IERC721Receiver.sol";
import {IERC165, ERC165} from "../ERC165/ERC165.sol";

import {ERC721Utils} from "./utils/ERC721Utils.sol";
import {Strings} from "../utils/Strings.sol";

abstract contract ERC721 is ERC165, IERC721, IERC721Metadata {
    using Strings for uint256;

    string public name;
    string public symbol;

    mapping(uint256 tokenId => address) internal _ownerOf;
    mapping(address owner => uint256) internal _balanceOf;
    mapping(uint256 tokenId => address) public getApproved;
    mapping(address owner => mapping(address operator => bool)) public isApprovedForAll;

    // -------------------------------

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    // -------------------------------
    // METADATA LOGIC

    function _baseURI() internal pure virtual returns(string memory) {
        return "";
    }

    function tokenURI(uint256 tokenId) public view virtual returns(string memory) {
        require(_ownerOf[tokenId] != address(0), "Token not minted!");

        string memory baseURI = _baseURI();

        return bytes(baseURI).length > 0 ?
            string(abi.encodePacked(baseURI, tokenId.toString())) :
            "";
    }

    // -------------------------------
    // ERC721 LOGIC

    function ownerOf(uint256 tokenId) public view virtual returns(address) {
        require(_ownerOf[tokenId] != address(0), "Token not minted!");

        return _ownerOf[tokenId];
    }

    function balanceOf(address owner) public view virtual returns(uint256) {
        require(owner != address(0), "Owner cannot be zero address!");

        return _balanceOf[owner];
    }

    function approve(address spender, uint256 tokenId) public virtual {
        address _owner = ownerOf(tokenId);

        require(_owner == msg.sender || isApprovedForAll[_owner][msg.sender], "Not approved or owner!");

        require(spender != _owner, "Cannot approve to self!");

        getApproved[tokenId] = spender;

        emit Approval(_owner, spender, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        require(msg.sender != operator, "Cannot approve to self!");

        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner!");
        require(ownerOf(tokenId) == from, "Incorrect owner!");
        require(to != address(0), "to cannot be zero address!");

        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[tokenId] = to;

        delete getApproved[tokenId];

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual {
        transferFrom(from, to, tokenId);
        require(ERC721Utils._checkOnERC721Received(msg.sender, from, to, tokenId, data), "Transfer to non-erc721 receiver!");
    }

    // -------------------------------

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns(bool) {
        address owner = ownerOf(tokenId);

        return(
            spender == owner ||
            isApprovedForAll[owner][spender] ||
            getApproved[tokenId] == spender
        );
    }

    // -------------------------------
    // ERC165 LOGIC

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns(bool) {
        return 
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // -------------------------------
    // MINT/BURN LOGIC

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "to cannot be zero address!");
        require(_ownerOf[tokenId] == address(0), "Token already minted!");

        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(ERC721Utils._checkOnERC721Received(msg.sender, address(0), to, tokenId, data), "Mint to non-erc721 receiver!");
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        require(owner != address(0), "Token not minted!");
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner!");

        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[tokenId];

        delete getApproved[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }
}

// -------------------------------

abstract contract ERC721TokenReceiver is IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}