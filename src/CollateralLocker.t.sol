pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./CollateralLocker.sol";

contract CollateralLockerTest is DSTest {
    CollateralLocker locker;

    function setUp() public {
        locker = new CollateralLocker();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
