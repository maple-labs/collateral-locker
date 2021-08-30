// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.6.11;

import { DSTest } from "../../modules/ds-test/src/test.sol";
import { ERC20 }  from "../../modules/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

import { ICollateralLocker } from "../interfaces/ICollateralLocker.sol";

import { CollateralLockerFactory } from "../CollateralLockerFactory.sol";

import { Loan } from "./accounts/Loan.sol";

contract MockToken is ERC20 {

    constructor (string memory name, string memory symbol) ERC20(name, symbol) public {}

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

}

contract CollateralLockerFactoryTest is DSTest {

    function test_newLocker() external {
        CollateralLockerFactory factory = new CollateralLockerFactory();
        Loan                    loan    = new Loan();
        Loan                    notLoan = new Loan();
        MockToken               token   = new MockToken("TKN", "TKN");

        ICollateralLocker locker = ICollateralLocker(loan.collateralLockerFactory_newLocker(address(factory), address(token)));

        // Validate the storage of factory.
        assertEq(factory.owner(address(locker)), address(loan), "Invalid owner");
        assertTrue(factory.isLocker(address(locker)),           "Invalid isLocker");

        // Validate the storage of locker.
        assertEq(locker.loan(),                     address(loan),  "Incorrect loan address");
        assertEq(address(locker.collateralAsset()), address(token), "Incorrect address of collateral asset");

        // Assert that only the CollateralLocker owner (loan) can access funds
        token.mint(address(locker), 1);
        assertTrue(!notLoan.try_collateralLocker_pull(address(locker), address(loan), 1), "Pull succeeded from notLoan");
        assertTrue(    loan.try_collateralLocker_pull(address(locker), address(loan), 1), "Pull failed from loan");
    }

}
