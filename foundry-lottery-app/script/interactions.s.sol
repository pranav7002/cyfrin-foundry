// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        address vrfCoordinator = config.vrfCoordinator;
        (uint256 subId,) = createSubscription(vrfCoordinator);

        return (subId, vrfCoordinator);
    }

    /*
    On Sepolia:
    address vrfCoordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B; // Real coordinator

    This cast:
    VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();

    Is equivalent to:
    1. EVM looks at address 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B
    2. Loads the bytecode stored at that address (the REAL coordinator's code)
    3. Finds createSubscription() function in that bytecode
    4. Executes the REAL coordinator's implementation
    */
    /*
    On Anvil:
    address vrfCoordinator = address(mockVrf); // Your deployed mock

    This cast:
    VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();

    Is equivalent to:
    1. EVM looks at address(mockVrf)
    2. Loads the bytecode stored at that address (the MOCK's code)
    3. Finds createSubscription() function in that bytecode
    4. Executes the MOCK's implementation
    */

    function createSubscription(address vrfCoordinator) public returns (uint256, address) {
        console.log("Creating sub on Chain Id", block.chainid);
        vm.startBroadcast();
        /*
        This next line typecasts vrfCoordinator to a VRFCoordinatorV2_5Mock. Hence, the confusing sytax
        */
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();

        console.log("Sub Id is ", subId);

        return (subId, vrfCoordinator);
    }

    function run() public {}
}

contract FundSubscription is Script {
    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        address vrfCoordinator = config.vrfCoordinator;
        uint256 subscriptionId = config.subscriptionId;
    }
    function run() public {}
}
