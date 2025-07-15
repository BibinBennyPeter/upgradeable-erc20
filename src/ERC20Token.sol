// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "@openzeppelin/contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/contracts/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/contracts/utils/PausableUpgradeable.sol";

contract ERC20Token is
    ERC20Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{
    error ZeroAmountError();
    error TransferFailedError();
    error InsufficientReserveError(uint256 requested, uint256 available);
    error EmptyStringError();

    constructor() {
        _disableInitializers();
    }

    function initialize(string memory name, string memory symbol) public initializer {
        if (bytes(name).length == 0 || bytes(symbol).length == 0) revert EmptyStringError();

        __ERC20_init(name, symbol);
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
    }

    /// @notice Function to authorize upgrades to the contract.
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /// @notice Mints tokens to a specified address.
    function mint(address _to, uint256 _amount) external onlyOwner {
        if (_amount == 0) revert ZeroAmountError();
        _mint(_to, _amount);
    }

    /// @notice Burns tokens from a specified address.
    function burn(address _from, uint256 _amount) external onlyOwner {
        if (_amount == 0) revert ZeroAmountError();
        _burn(_from, _amount);
    }

    /// @notice Reedeems tokens for Ether. Pegged 1:1 with Ether for demo.
    function redeem(uint256 _amount) external nonReentrant whenNotPaused {
        if (_amount == 0) revert ZeroAmountError();
        if (address(this).balance < _amount) revert InsufficientReserveError(_amount, address(this).balance);
        _burn(msg.sender, _amount);
        (bool success,) = msg.sender.call{value: _amount}("");
        if (!success) revert TransferFailedError();
    }

    /// @notice Pauses the contract, preventing token transfers.
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpauses the contract, allowing token transfers.
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Internal function to update balances, overridden to include pausable functionality.
    function _update(address from, address to, uint256 amount) internal override whenNotPaused {
        super._update(from, to, amount);
    }

    /// @notice Allows the contract to receive Ether.
    receive() external payable {}

    /// @notice Reserve storage gap for future upgrades.
    uint256[50] private __gap;
}
