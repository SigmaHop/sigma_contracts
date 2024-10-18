// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

interface ISigmaHop {
    /// @notice Sets the hop address for a specific chain
    /// @param chainId The ID of the target chain
    /// @param hopAddress The address of the hop on the target chain
    /// @dev Only callable by the genesis address
    function setHopAddress(uint16 chainId, address hopAddress) external;

    /// @notice Quotes the cost of a cross-chain deposit
    /// @param targetChain The ID of the target chain
    /// @return cost The estimated cost of the cross-chain deposit in native tokens
    function quoteCrossChainDeposit(
        uint16 targetChain
    ) external view returns (uint256 cost);

    /// @notice Initiates a cross-chain deposit
    /// @param targetChain The ID of the target chain
    /// @param recipient The address of the recipient on the target chain
    /// @param amount The amount of USDC to deposit
    /// @dev This function is payable and requires the exact amount returned by quoteCrossChainDeposit
    function sendCrossChainDeposit(
        uint16 targetChain,
        address recipient,
        uint256 amount
    ) external payable;

    /// @notice Retrieves the hop address for a specific chain
    /// @param chainId The ID of the chain
    /// @return The hop address for the specified chain
    function HopAddresses(uint16 chainId) external view returns (address);
}
