// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC1155Receiver} from "../IERC1155Receiver.sol";

library ERC1155Utils {
    function checkOnERC1155Received(
        address operator, 
        address from, 
        address to, 
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal returns(bool) {
        if(to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns(bytes4 retval) {
                return retval == IERC1155Receiver.onERC1155Received.selector;
            } catch(bytes memory reason) {
                if(reason.length == 0) {
                    revert("Transfer to non-erc1155 receiver!");
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

    function checkOnERC1155BatchReceived(
        address operator, 
        address from, 
        address to, 
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal returns(bool) {
        if(to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns(bytes4 retval) {
                return retval == IERC1155Receiver.onERC1155BatchReceived.selector;
            } catch(bytes memory reason) {
                if(reason.length == 0) {
                    revert("Transfer to non-erc1155 receiver!");
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