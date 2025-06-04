// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/IdentityUploader.sol";

contract DeployMonthlyReport is Script {
    function run() external {
        address _platformAddress = 0x12E2C1e3A8CA617689A4E4E6d6a098Faf08B8189;
        vm.startBroadcast();
        new MonthlyReport(_platformAddress);
        vm.stopBroadcast();
    }
}
