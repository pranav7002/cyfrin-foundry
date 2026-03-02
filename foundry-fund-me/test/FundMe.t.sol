// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 public constant INITIAL_BALANCE = 10e18;
    uint256 public constant INITIAL_FUNDING_AMOUNT = 0.1 ether;
    uint256 public constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, INITIAL_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testDoesFundMeRevert() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: INITIAL_FUNDING_AMOUNT}();

        assertEq(fundMe.addressToAmountFunded(USER), INITIAL_FUNDING_AMOUNT);
    }

    function testFunderIsAddedToArray() public {
        vm.prank(USER);
        fundMe.fund{value: INITIAL_FUNDING_AMOUNT}();

        address _address = fundMe.funders(0);
        assertEq(_address, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: INITIAL_FUNDING_AMOUNT}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        //Arrange
        uint256 initialBalanceOfOwnerAccount = fundMe.i_owner().balance;
        uint256 initialBalanceOfContract = address(fundMe).balance;

        //Act
        // uint256 gasStart = gasLeft();

        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.i_owner());
        fundMe.withdraw();

        // uint256 gasEnd = gasLeft();
        // uint256 gasUsed = (gasStart - gasEnd)*tx.gasprice;

        //Assert
        uint256 finalBalanceOfOwnerAccount = fundMe.i_owner().balance;
        uint256 finalBalanceOfContract = address(fundMe).balance;
        assertEq(
            finalBalanceOfOwnerAccount,
            INITIAL_FUNDING_AMOUNT + initialBalanceOfOwnerAccount
        );
        assertEq(finalBalanceOfContract, 0);
    }

    function testWithdrawWithMultipleFunders() public funded {
        uint160 indexOfFunder;
        uint160 numberOfFunders = 10;

        for (
            indexOfFunder = 1;
            indexOfFunder <= numberOfFunders;
            indexOfFunder++
        ) {
            hoax(address(indexOfFunder), INITIAL_FUNDING_AMOUNT);
            fundMe.fund{value: INITIAL_FUNDING_AMOUNT}();
        }

        uint256 initialBalanceOfOwnerAccount = fundMe.i_owner().balance;
        uint256 initialBalanceOfContract = address(fundMe).balance;

        vm.startPrank(fundMe.i_owner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 finalBalanceOfOwnerAccount = fundMe.i_owner().balance;
        uint256 finalBalanceOfContract = address(fundMe).balance;
        assertEq(
            finalBalanceOfOwnerAccount,
            initialBalanceOfContract + initialBalanceOfOwnerAccount
        );
        assertEq(finalBalanceOfContract, 0);
    }

    function testCheaperWithdrawWithMultipleFunders() public funded {
        uint160 indexOfFunder;
        uint160 numberOfFunders = 10;

        for (
            indexOfFunder = 1;
            indexOfFunder <= numberOfFunders;
            indexOfFunder++
        ) {
            hoax(address(indexOfFunder), INITIAL_FUNDING_AMOUNT);
            fundMe.fund{value: INITIAL_FUNDING_AMOUNT}();
        }

        uint256 initialBalanceOfOwnerAccount = fundMe.i_owner().balance;
        uint256 initialBalanceOfContract = address(fundMe).balance;

        vm.startPrank(fundMe.i_owner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint256 finalBalanceOfOwnerAccount = fundMe.i_owner().balance;
        uint256 finalBalanceOfContract = address(fundMe).balance;
        assertEq(
            finalBalanceOfOwnerAccount,
            initialBalanceOfContract + initialBalanceOfOwnerAccount
        );
        assertEq(finalBalanceOfContract, 0);
    }
}
