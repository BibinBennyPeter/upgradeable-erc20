pragma solidity 0.8.22;

import "../lib/forge-std/src/Test.sol";
import {console} from "../lib/forge-std/src/console.sol";
import "../src/ERC20Token.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import "@openzeppelin/contracts-upgradeable/contracts/utils/PausableUpgradeable.sol";
import "./ERC20TokenV2.sol";

contract ERC20TokenTest is Test {
    ERC20Token token;
    address owner;
    address user;

    function setUp() public {
        owner = address(this);
        user = makeAddr("user");
        vm.deal(user, 100 ether);
        token = ERC20Token(payable(deployProxy()));
    }

    function deployProxy() internal returns (address) {
        ERC20Token _token = new ERC20Token();
        ERC1967Proxy proxy =
            new ERC1967Proxy(address(_token), abi.encodeWithSelector(_token.initialize.selector, "TestToken", "TTK"));
        return address(proxy);
    }

    function testInitialize() public view {
        assertEq(token.name(), "TestToken", "Token name should be initialized correctly");
        assertEq(token.symbol(), "TTK", "Token symbol should be initialized correctly");
        assertEq(token.decimals(), 18, "Token decimals should be initialized to 18");
        assertEq(owner, token.owner(), "Owner should be set correctly");
    }

    function testMintByOwner() public {
        uint256 mintAmount = 100 ether;
        token.mint(user, mintAmount);

        assertEq(token.balanceOf(user), mintAmount, "User should have the minted amount");
        assertEq(token.totalSupply(), mintAmount, "Total supply should be updated after mint");
    }

    function testMintByNonOwner() public {
        uint256 mintAmount = 100 ether;
        vm.prank(user);

        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, user));
        token.mint(user, mintAmount);
    }

    function testMintByZeroAmount() public {
        vm.expectRevert(ERC20Token.ZeroAmountError.selector);
        token.mint(user, 0);
    }

    function testMintToZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        token.mint(address(0), 100 ether);
    }

    function testBurnByOwner() public {
        uint256 mintAmount = 100 ether;
        token.mint(user, mintAmount);

        uint256 burnAmount = 50 ether;
        token.burn(user, burnAmount);

        assertEq(token.balanceOf(user), mintAmount - burnAmount, "User should have the remaining balance after burn");
        assertEq(token.totalSupply(), mintAmount - burnAmount, "Total supply should be updated after burn");
    }

    function testBurnByNonOwner() public {
        uint256 mintAmount = 100 ether;
        token.mint(user, mintAmount);

        vm.prank(user);
        uint256 burnAmount = 50 ether;

        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, user));
        token.burn(user, burnAmount);
    }

    function testBurnByZeroAmount() public {
        vm.expectRevert(ERC20Token.ZeroAmountError.selector);
        token.burn(user, 0);
    }

    function testBurnMoreThanBalance() public {
        uint256 mintAmount = 100 ether;
        token.mint(user, mintAmount);

        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, user, mintAmount, mintAmount + 1)
        );
        token.burn(user, mintAmount + 1);
    }

    function testRedeem() public {
        vm.deal(address(token), 100 ether); // Ensure the contract has enough Ether to redeem
        uint256 mintAmount = 10 ether;
        token.mint(user, mintAmount);
        assertEq(token.balanceOf(user), mintAmount, "User should have the minted amount before redeem");

        vm.startPrank(user);
        token.redeem(mintAmount);
        vm.stopPrank();

        assertEq(token.balanceOf(user), 0, "User should have zero balance after redeem");
        assertEq(token.totalSupply(), 0, "Total supply should be zero after redeem");
        assertEq(address(token).balance, 90 ether, "Token contract should have 90 ether after redeem");
    }

    function testRedeemZeroAmount() public {
        vm.expectRevert(ERC20Token.ZeroAmountError.selector);
        token.redeem(0);
    }

    function testRedeemInsufficientReserve() public {
        vm.deal(address(token), 50 ether); // Ensure the contract has less Ether than the redeem amount
        uint256 mintAmount = 100 ether;
        token.mint(user, mintAmount);

        vm.startPrank(user);
        vm.expectRevert(abi.encodeWithSelector(ERC20Token.InsufficientReserveError.selector, mintAmount, 50 ether));
        token.redeem(mintAmount);
        vm.stopPrank();
    }

    function testPauseUnpause() public {
        token.mint(owner, 100 ether);
        vm.deal(address(token), 100 ether);
        console.log("Owner balance before transfer:", token.balanceOf(owner));

        token.pause();
        assertTrue(token.paused(), "Token should be paused");

        vm.expectRevert(abi.encodeWithSelector(PausableUpgradeable.EnforcedPause.selector));
        token.transfer(user, 1 ether);

        vm.expectRevert(abi.encodeWithSelector(PausableUpgradeable.EnforcedPause.selector));
        token.mint(user, 1 ether);

        vm.expectRevert(abi.encodeWithSelector(PausableUpgradeable.EnforcedPause.selector));
        token.redeem(1 ether);

        token.unpause();
        assertFalse(token.paused(), "Token should be unpaused");

        token.transfer(user, 50 ether);
        assertEq(token.balanceOf(owner), 50 ether, "User should have transferred tokens after unpause");
        
        vm.startPrank(user);
        token.redeem(10 ether);

        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, user));
        token.pause();
        vm.stopPrank();
    }

    function testUpgrade() public {
        token.mint(user, 155 ether);
        assertEq(token.balanceOf(user), 155 ether, "User should have 155 tokens before upgrade");
        // Deploy the new version of the token
        ERC20TokenV2 v2 = new ERC20TokenV2();

        // Upgrade the proxy to the new implementation
        token.upgradeToAndCall(address(v2), "");

        // Verify the upgrade
        assertEq(ERC20TokenV2(payable(address(token))).version(), "v2", "Token version should be updated to v2");

        // Check if upgrade preserved the state
        assertEq(token.balanceOf(user), 155 ether, "User should still have 155 tokens after upgrade");
    }

    function testUpgradeByNonOwner() public {
        ERC20TokenV2 newToken = new ERC20TokenV2();
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, user));
        token.upgradeToAndCall(address(newToken), "");
    }
}
