// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import {Context} from "./Context.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

abstract contract Sigma2771Context is Context {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address private _trustedForwarder;

    /**
     * @notice Sets the trusted forwarder for the context, could be called only once.
     * @param forwarder The forwarder to be trusted
     */
    function setupTrustedForwarder(address forwarder) internal {
        require(_trustedForwarder == address(0), "Forwarder already set");
        require(forwarder != address(0), "Invalid trusted forwarder");
        _trustedForwarder = forwarder;
    }

    /**
     * @notice Charges the fees for the transaction.
     * @param startGas Gas used before calling the function
     * @param gasPrice gas price of the transaction
     * @param baseGas base gas deducted by the relayer
     * @param GasTank address of the GasTank
     * @param token address of the token
     * @param wormholeFees fees to be charged in ETH
     * @param wormholeFeesToken fees to be charged in token
     */
    function chargeFees(
        uint256 startGas,
        uint256 gasPrice,
        uint256 baseGas,
        address GasTank,
        address token,
        uint256 wormholeFees,
        uint256 wormholeFeesToken
    ) internal {
        uint256 gasUsed = startGas - gasleft();
        uint256 gasFee = (gasUsed + baseGas) * gasPrice;

        if (token != address(0)) {
            uint8 decimals = IERC20Metadata(token).decimals();

            bool success = IERC20(token).transfer(
                GasTank,
                (gasFee + wormholeFeesToken) / 10 ** (18 - decimals)
            );

            if (!success) {
                revert("Fee transfer failed");
            }
        } else {
            (bool success, ) = GasTank.call{value: gasFee + wormholeFees}("");
            if (!success) {
                revert("Fee transfer failed");
            }
        }
    }

    /**
     * @dev Returns the address of the trusted forwarder.
     */
    function trustedForwarder() public view virtual returns (address) {
        return _trustedForwarder;
    }

    /**
     * @dev Indicates whether any particular address is the trusted forwarder.
     */
    function isTrustedForwarder(
        address forwarder
    ) public view virtual returns (bool) {
        return forwarder == trustedForwarder();
    }

    /**
     * @dev Modifier to check if the caller is the trusted forwarder.
     */
    modifier onlyTrustedForwarder() {
        require(
            isTrustedForwarder(msg.sender),
            "Caller is not the trusted forwarder"
        );
        _;
    }

    /**
     * @dev Modifier to check if the caller is not the trusted forwarder.
     */
    modifier notTrustedForwarder() {
        require(
            !isTrustedForwarder(msg.sender),
            "Caller is the trusted forwarder"
        );
        _;
    }
}
