// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./SigmaProxy.sol";
import "../external/Sigma2771Context.sol";
import "../common/GenesisManager.sol";
import "../interfaces/ISigmaUSDCVault.sol";

contract SigmaProxyFactory is GenesisManager {
    event ProxyCreation(SigmaProxy indexed proxy, address singleton);

    event SingletonCreated(address indexed singleton);

    // The address of the current singleton contract used as the master copy for proxy contracts.
    address private CurrentSingleton;

    // The address of the USDCToken contract
    address public USDCToken;

    // The address of the trusted forwarder
    address public trustedForwarder;

    // The address of the gas tank
    address public gasTank;

    constructor(
        address _currentSingleton,
        address _USDCToken,
        address _trustedForwarder,
        address _gasTank
    ) {
        CurrentSingleton = _currentSingleton;
        USDCToken = _USDCToken;
        trustedForwarder = _trustedForwarder;
        gasTank = _gasTank;
    }

    /// @dev Allows to retrieve the creation code used for the Proxy deployment. With this it is easily possible to calculate predicted address.
    function proxyCreationCode() public pure returns (bytes memory) {
        return type(SigmaProxy).creationCode;
    }

    /**
     * @notice Deploys a new proxy contract and sets the owner.
     * @param owner The owner of the proxy contract
     * @return proxy The address of the newly deployed proxy contract
     */
    function deployProxy(address owner) internal returns (SigmaProxy proxy) {
        require(
            isContract(CurrentSingleton),
            "Singleton contract not deployed"
        );

        bytes32 salt = keccak256(abi.encodePacked(owner));

        bytes memory deploymentData = abi.encodePacked(
            type(SigmaProxy).creationCode
        );
        // solhint-disable-next-line no-inline-assembly
        assembly {
            proxy := create2(
                0x0,
                add(0x20, deploymentData),
                mload(deploymentData),
                salt
            )
        }

        require(address(proxy) != address(0), "Create2 call failed");

        proxy.setupSingleton(CurrentSingleton);

        bytes memory initializer = getInitializer(
            owner,
            USDCToken,
            trustedForwarder,
            gasTank
        );

        // solhint-disable-next-line no-inline-assembly
        assembly {
            if eq(
                call(
                    gas(),
                    proxy,
                    0,
                    add(initializer, 0x20),
                    mload(initializer),
                    0,
                    0
                ),
                0
            ) {
                revert(0, 0)
            }
        }

        emit ProxyCreation(proxy, CurrentSingleton);
    }

    /**
     * @notice Creates a new proxy contract and sets the owner.
     * @param owner The owner of the proxy contract
     * @return proxy The address of the newly deployed proxy contract
     */
    function createProxy(address owner) external returns (SigmaProxy proxy) {
        return deployProxy(owner);
    }

    /**
     * @notice Returns the address of the proxy contract for a given owner.
     * @param owner The owner of the proxy contract
     */
    function getSigmaProxy(
        address owner
    ) public view returns (address sigmaProxy) {
        bytes32 salt = keccak256(abi.encodePacked(owner));
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                address(this),
                                salt,
                                keccak256(type(SigmaProxy).creationCode)
                            )
                        )
                    )
                )
            );
    }

    /**
     * @notice Returns the initializer data for the SigmaUSDCVault contract.
     * @param _owner The owner of the SigmaUSDCVault contract
     * @param _usdcToken The address of the USDC token
     * @param _forwarder The address of the trusted forwarder
     * @param _gasTank The address of the gas tank
     */
    function getInitializer(
        address _owner,
        address _usdcToken,
        address _forwarder,
        address _gasTank
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                ISigmaUSDCVault.setupSigmaUSDCVault.selector,
                _owner,
                _usdcToken,
                _forwarder,
                _gasTank
            );
    }

    /**
     * @notice Returns true if `account` is a contract.
     * @dev This function will return false if invoked during the constructor of a contract,
     *      as the code is not actually created until after the constructor finishes.
     * @param account The address being queried
     * @return True if `account` is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
