// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "../src/ERC20Token.sol";

contract ERC20TokenV2 is ERC20Token {
    function version() external pure returns (string memory) {
        return "v2";
    }
}
