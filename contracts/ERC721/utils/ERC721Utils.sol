// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC721Receiver} from "../IERC721Receiver.sol";

library ERC721Utils {
    function _checkOnERC721Received(
        address operator, 
        address from, 
        address to, 
        uint256 tokenId, 
        bytes memory data
    ) internal returns(bool) {
        if(to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(operator, from, tokenId, data) returns(bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch(bytes memory reason) {
                if(reason.length == 0) {
                    revert("Transfer to non-erc721 receiver!");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}