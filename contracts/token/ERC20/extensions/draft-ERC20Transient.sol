// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20} from "../ERC20.sol";

/**
 * @dev TODO
 */
abstract contract ERC20Transient is ERC20 {
    // TODO: update this constant
    uint256 internal constant ALLOWANCE_SLOT_SEED = 0x7f5e9f20;

    // TODO: update this constant
    uint256 internal constant APPROVAL_EVENT_SIGNATURE =
        0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

    // TODO: update this constant
    uint256 internal constant INSUFFICIENT_ALLOWANCE_SELECTOR =
        0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

    // TODO: add comments
    function allowance(address owner, address spender) public view virtual override returns (uint256 value) {
        assembly ("memory-safe") {
            mstore(0x20, spender)
            mstore(0x0c, ALLOWANCE_SLOT_SEED)
            mstore(0x00, owner)
            value := tload(keccak256(0x0c, 0x34))
        }
    }

    // TODO: add comments
    function transientApprove(address spender, uint256 value) public virtual returns (bool) {
        assembly ("memory-safe") {
            // Compute the allowance slot and store the value.
            mstore(0x20, spender)
            mstore(0x0c, ALLOWANCE_SLOT_SEED)
            mstore(0x00, caller())
            tstore(keccak256(0x0c, 0x34), value)
            // Emit the {Approval} event.
            mstore(0x00, value)
            log3(0x00, 0x20, APPROVAL_EVENT_SIGNATURE, caller(), shr(96, mload(0x2c)))
        }
        return true;
    }

    // TODO: add comments
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual override {
        assembly ("memory-safe") {
            // Get the transient allowance.
            mstore(0x20, spender)
            mstore(0x0c, ALLOWANCE_SLOT_SEED)
            mstore(0x00, owner)
            let allowanceSlot := keccak256(0x0c, 0x34)
            let allowance_ := tload(allowanceSlot)

            // If the allowance is not the maximum uint256 value.
            if add(allowance_, 1) {
                // Revert if the value to be transferred exceeds the allowance.
                if gt(value, allowance_) {
                    // TODO: update this selector with the right one of ERC20InsufficientAllowance(...)
                    mstore(0x00, 0x13be252b)
                    mstore(0x04, spender)
                    mstore(0x24, allowance_)
                    mstore(0x44, value)
                    revert(0, 0x64)
                }
                // Subtract and store the updated allowance.
                tstore(allowanceSlot, sub(allowance_, value))
            }
        }
    }
}
