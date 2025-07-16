# Upgradeable ERC20 Token Project

This repository demonstrates a production‑grade, upgradeable ERC20 token implemented in Solidity, using OpenZeppelin's upgradeable contracts and Forge for testing.

## Structure

```
├── src/
│   └── ERC20Token.sol       # Core upgradeable token contract
├── test/
│   ├── ERC20Token.t.sol     # Comprehensive Forge tests
│   └── ERC20TokenV2.sol     
├── lib/
│   └── openzeppelin-contracts-upgradeable/  # OZ upgradeable contracts submodule
├── remappings.txt           # Import remappings for Forge
├── foundry.toml             # Foundry configuration
└── README.md                # Root overview
```

## Getting Started

1. **Install Foundry**:

   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Clone and initialize submodules**:

   ```bash
   git clone https://github.com/BibinBennyPeter/upgradeable-erc20.git
   cd upgradeable-erc20
   git submodule update --init --recursive
   ```

3. **Build & Test**:

   ```bash
   forge build
   forge test
   ```

4. \*\*4. **Inspect Contracts**:

   * [`src/ERC20Token.sol`](https://github.com/BibinBennyPeter/upgradeable-erc20/blob/main/src/ERC20Token.sol): implements an upgradeable ERC20 token with mint, burn, redeem, pause/unpause, and UUPS upgrade logic.
   * [`src/README.md`](src/README.md): detailed contract documentation.

5. **Review Tests**:

   * [`test/ERC20Token.t.sol`](https://github.com/BibinBennyPeter/upgradeable-erc20/blob/main/test/ERC20Token.t.sol): tests initialization, mint/burn, redeem edge cases, pause/unpause, and upgrade flows.
   * [`test/README.md`](test/README.md): detailed test suite documentation. **Review Tests**:
   * `test/ERC20Token.t.sol`: tests initialization, mint/burn, redeem edge cases, pause/unpause, and upgrade flows.

---

Explore each folder's README for more detailed explanations of contracts and tests.
