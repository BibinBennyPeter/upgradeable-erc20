# `src` : ERC20Token Contract

This directory contains the core upgradeable ERC20 token implementation.

## File

* **`ERC20Token.sol`**

  * An upgradeable ERC20 token using OpenZeppelin's UUPS proxy pattern.
  * Features:

    * **Initialization** via `initialize(string name, string symbol)` instead of constructor.
    * **Access Control**: Owner‑only `mint` and `burn` functions using `OwnableUpgradeable`.
    * **Redeem**: `redeem(uint256 amount)` burns tokens and refunds ETH at a 1:1 ratio for demo.
    * **Pause/Unpause**: Emergency halt of transfers and redeems via `PausableUpgradeable`.
    * **Reentrancy Guard**: `nonReentrant` on `redeem` to prevent reentrancy attacks.
    * **Upgradeable**: UUPS pattern with `_authorizeUpgrade` guarded by `onlyOwner`.
    * **Storage Gap**: `uint256[50] private __gap;` to reserve space for future state variables.

## Usage

1. Deploy the **implementation** and **proxy** in one step via `ERC1967Proxy`, supplying the `initialize` selector.
2. Interact with the proxy address for all token operations.
3. Call `upgradeToAndCall` to swap to a new implementation when needed.

Refer to [README.md](../README.md) for project‑level instructions and testing guidelines.
