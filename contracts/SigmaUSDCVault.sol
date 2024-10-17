// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./common/Singleton.sol";
import "./common/StorageAccessible.sol";
import "./external/Sigma2771Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SigmaUSDCVault is Singleton, StorageAccessible, Sigma2771Context {
    event SigmaUSDCVaultInitialized(
        address owner,
        address USDCToken,
        address trustedForwarder
    );

    // Owner of the Vault
    address private owner;

    // USDC Token
    IERC20 public USDCToken;

    // Gas Tank
    address private gasTank;

    /**
     * @notice Sets the SigmaUSDCVault contract.
     * @param _owner  The owner of the contract
     * @param _USDCToken  The address of the USDC token
     * @param _trustedForwarder   The address of the trusted forwarder
     * @param _gasTank  The address of the gas tank
     */
    function setupSigmaUSDCVault(
        address _owner,
        address _USDCToken,
        address _trustedForwarder,
        address _gasTank
    ) public {
        require(owner == address(0), "Vault already set");
        require(_USDCToken != address(0), "Invalid USDC token");
        owner = _owner;
        USDCToken = IERC20(_USDCToken);
        setupTrustedForwarder(_trustedForwarder);
        gasTank = _gasTank;

        emit SigmaUSDCVaultInitialized(_owner, _USDCToken, _trustedForwarder);
    }

    /**
     * @notice Transfers the USDC token to the contract.
     * @param _signer  The address of the signer
     * @param _to  The address of the receiver
     * @param _amount  The amount of USDC token to transfer
     * @param gasPrice  The gas price of the transaction
     * @param baseGas  The base gas of the transaction
     */
    function transferToken(
        address _signer,
        address _to,
        uint256 _amount,
        uint256 gasPrice,
        uint256 baseGas
    ) public onlyTrustedForwarder {
        require(_signer == owner, "Caller is not the owner");

        uint256 startGas = gasleft();

        USDCToken.transfer(_to, _amount);

        chargeFees(startGas, gasPrice, baseGas, gasTank, address(USDCToken), 0);
    }

    function transferTokenCrossChain(
        address _signer,
        uint16 _destChain,
        address _to,
        uint256 _amount,
        uint256 gasPrice,
        uint256 baseGas
    ) public onlyTrustedForwarder {
        require(_signer == owner, "Caller is not the owner");

        uint256 startGas = gasleft();

        // Implement Cross Chain Transfer

        // Add Wormhole Fees
        chargeFees(startGas, gasPrice, baseGas, gasTank, address(USDCToken), 0);
    }
}
