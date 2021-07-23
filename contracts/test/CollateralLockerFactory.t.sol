// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import { DSTest } from "../../modules/ds-test/src/test.sol";
import { ERC20 }  from "../../modules/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

import { ICollateralLocker } from "../interfaces/ICollateralLocker.sol";

import { CollateralLockerFactory } from "../CollateralLockerFactory.sol";

contract MintableToken is ERC20 {

    constructor (string memory name, string memory symbol) ERC20(name, symbol) public {}

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

}

contract CollateralLockerOwner {

    function collateralLockerFactory_newLocker(address factory, address token) external returns (address) {
        return address(ICollateralLocker(CollateralLockerFactory(factory).newLocker(token)));
    }

    function try_collateralLockerFactory_newLocker(address factory, address token) external returns (bool ok, address locker) {
        bytes memory data;
        (ok, data) = factory.call(abi.encodeWithSignature("newLocker(address)", token));
        (locker) = abi.decode(data, (address));
    }

    function collateralLocker_pull(address locker, address destination, uint256 amount) external {
        ICollateralLocker(locker).pull(destination, amount);
    }

    function try_collateralLocker_pull(address locker, address destination, uint256 amount) external returns (bool ok) {
        (ok,) = locker.call(abi.encodeWithSignature("pull(address,uint256)", destination, amount));
    }

}

contract CollateralLockerFactoryTest is DSTest {

    function test_newLocker() public {
        CollateralLockerFactory factory = new CollateralLockerFactory();
        MintableToken token = new MintableToken("TKN", "TKN");
        CollateralLockerOwner owner = new CollateralLockerOwner();

        ICollateralLocker locker = ICollateralLocker(owner.collateralLockerFactory_newLocker(address(factory), address(token)));

        // Validate the storage of factory.
        assertEq(factory.owner(address(locker)), address(owner), "Invalid owner");
        assertTrue(factory.isLocker(address(locker)), "Invalid isLocker");

        // Validate the storage of locker.
        assertEq(locker.loan(), address(owner),                     "Incorrect loan address");
        assertEq(address(locker.collateralAsset()), address(token), "Incorrect address of collateral asset");

        // Assert that only the CollateralLocker owner can access funds
        token.mint(address(locker), 1);
        assertTrue(owner.try_collateralLocker_pull(address(locker), address(owner), 1), "Pull failed");
    }

}
