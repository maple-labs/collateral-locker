// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.6.11;

import { ICollateralLocker }        from "../../interfaces/ICollateralLocker.sol";
import { ICollateralLockerFactory } from "../../interfaces/ICollateralLockerFactory.sol";

contract Loan {

    /************************/
    /*** Direct Functions ***/
    /************************/

    function collateralLockerFactory_newLocker(address factory, address token) external returns (address) {
        return ICollateralLockerFactory(factory).newLocker(token);
    }

    function collateralLocker_pull(address locker, address destination, uint256 amount) external {
        ICollateralLocker(locker).pull(destination, amount);
    }

    /*********************/
    /*** Try Functions ***/
    /*********************/

    function try_collateralLockerFactory_newLocker(address factory, address token) external returns (bool ok) {
        (ok,) = factory.call(abi.encodeWithSelector(ICollateralLockerFactory.newLocker.selector, token));
    }

    function try_collateralLocker_pull(address locker, address destination, uint256 amount) external returns (bool ok) {
        (ok,) = locker.call(abi.encodeWithSelector(ICollateralLocker.pull.selector, destination, amount));
    }

}
