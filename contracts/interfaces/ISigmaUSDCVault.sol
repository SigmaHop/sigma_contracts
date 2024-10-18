// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title ISigmaUSDCVault
/// @notice Interface for the SigmaUSDCVault contract
interface ISigmaUSDCVault {
    /// @notice Emitted when the SigmaUSDCVault is initialized
    /// @param owner The address of the owner
    /// @param USDCToken The address of the USDC token
    /// @param trustedForwarder The address of the trusted forwarder
    event SigmaUSDCVaultInitialized(
        address owner,
        address USDCToken,
        address trustedForwarder
    );

    /// @notice Sets up the SigmaUSDCVault contract
    /// @param _owner The owner of the contract
    /// @param _USDCToken The address of the USDC token
    /// @param _trustedForwarder The address of the trusted forwarder
    /// @param _gasTank The address of the gas tank
    function setupSigmaUSDCVault(
        address _owner,
        address _USDCToken,
        address _trustedForwarder,
        address _gasTank
    ) external;

    /// @notice Transfers USDC tokens
    /// @param _signer The address of the signer
    /// @param _to The address of the receiver
    /// @param _amount The amount of USDC token to transfer
    /// @param gasPrice The gas price of the transaction
    /// @param baseGas The base gas of the transaction
    function transferToken(
        address _signer,
        address _to,
        uint256 _amount,
        uint256 gasPrice,
        uint256 baseGas
    ) external;

    /// @notice Transfers USDC tokens cross-chain
    /// @param _sigmaHop The address of the SigmaHop contract
    /// @param _signer The address of the signer
    /// @param _destChain The destination chain
    /// @param _to The address of the receiver
    /// @param _amount The amount of USDC token to transfer
    /// @param gasPrice The gas price of the transaction
    /// @param baseGas The base gas of the transaction
    function transferTokenCrossChain(
        address _sigmaHop,
        address _signer,
        uint16 _destChain,
        address _to,
        uint256 _amount,
        uint256 gasPrice,
        uint256 baseGas
    ) external;

    /// @notice Gets the USDC token address
    /// @return The IERC20 interface of the USDC token
    function USDCToken() external view returns (IERC20);
}
