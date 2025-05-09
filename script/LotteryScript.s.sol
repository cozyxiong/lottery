// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {EmptyContract} from "../src/utils/EmptyContract.sol";
import "../src/contract/Lottery.sol";
import "forge-std/Vm.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract LotteryScript is Script {

    IERC20 public constant CozyXiongToken = IERC20(address(0xB33CE01d6242c73eB318661Cf0eeE8Ace7680b33));

    EmptyContract public emptyContract;
    Lottery public lottery;
    Lottery public lotteryImplementation;
    ProxyAdmin public lotteryProxyAdmin;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast();

        emptyContract = new EmptyContract();
        TransparentUpgradeableProxy lotteryProxy = new TransparentUpgradeableProxy(address(emptyContract), deployerAddress, "");
        lottery = Lottery(payable(address(lotteryProxy)));
        lotteryImplementation = new Lottery();
        lotteryProxyAdmin = ProxyAdmin(getProxyAdminAddress(address(lotteryProxy)));
        lotteryProxyAdmin.upgradeAndCall(
            ITransparentUpgradeableProxy(address(lottery)),
            address(lotteryImplementation),
            abi.encodeWithSelector(
                Lottery.initialize.selector,
                msg.sender,
                CozyXiongToken
            )
        );
        vm.stopBroadcast();

        console.log("lottery proxy contract deployed at:", address(lottery));
    }

    function getProxyAdminAddress(address proxy) internal view returns (address) {
        address CHEATCODE_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;
        Vm vm = Vm(CHEATCODE_ADDRESS);

        bytes32 adminSlot = vm.load(proxy, ERC1967Utils.ADMIN_SLOT);
        return address(uint160(uint256(adminSlot)));
    }
}
