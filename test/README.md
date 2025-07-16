# `test` : Forge Test Suite

This directory contains comprehensive Forge-based tests for the `ERC20Token` contract.

## Files

* **`ERC20Token.t.sol`**

  * Tests initialization, mint, burn, redeem, pause/unpause, and UUPS upgrade flows.
  * Uses `forge-std/Test.sol` for cheat codes:

    * `makeAddr(…)` to generate deterministic test addresses.
    * `vm.deal(…)` to fund accounts and the contract with ETH.
    * `vm.prank` / `vm.startPrank` & `vm.stopPrank` to impersonate callers.
    * `vm.expectRevert(…)` to catch custom errors and access-control failures.
  * Covers:

    1. **Initialization**: correct name, symbol, decimals, owner.
    2. **Mint/Burn**: owner vs non-owner behavior, zero-amount, underflow.
    3. **Redeem**: successful ETH payout, zero-amount, insufficient reserve, pause guard.
    4. **Pause/Unpause**: blocking/re-enabling transfers & redeems, event checks.
    5. **UUPS Upgrades**: owner-only upgrade, state persistence, V2 contract functionality.

* **`ERC20TokenV2.sol`**

  * Minimal extension of the original contract adding a `version()` method.
  * Used to verify that `upgradeToAndCall` correctly points the proxy to a new implementation.

## Running Tests

From the project root:

```bash
forge test
```

To see detailed logs (e.g., `console.log` output):

```bash
forge test -vvv
```

Refer to the [README](../README.md) for setup and overall project instructions.
