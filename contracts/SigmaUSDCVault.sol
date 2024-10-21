// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./common/Singleton.sol";
import "./common/StorageAccessible.sol";
import "./external/Sigma2771Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ISigmaHop.sol";

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

        if (_to == address(0)) {
            IERC20(USDCToken).transfer(owner, _amount);
        } else {
            IERC20(USDCToken).transfer(_to, _amount);
        }

        chargeFees(startGas, gasPrice, baseGas, gasTank, address(USDCToken), 0);
    }

    /**
     * @notice Transfers the USDC token to the contract.
     * @param _sigmaHop  The address of the SigmaHop contract
     * @param _signer  The address of the signer
     * @param _destChain  The destination chain
     * @param _to  The address of the receiver
     * @param _amount  The amount of USDC token to transfer
     * @param gasPrice  The gas price of the transaction
     * @param baseGas  The base gas of the transaction
     */
    function transferTokenCrossChain(
        address _sigmaHop,
        address _signer,
        uint16 _destChain,
        address _to,
        uint256 _amount,
        uint256 gasPrice,
        uint256 baseGas
    ) public payable onlyTrustedForwarder {
        require(_signer == owner, "Caller is not the owner");

        uint256 startGas = gasleft();

        // Implement Cross Chain Transfer
        uint256 hopFees = ISigmaHop(_sigmaHop).quoteCrossChainDeposit(
            _destChain
        );

        require(msg.value == hopFees, "Fund requirements not met");

        IERC20(USDCToken).approve(_sigmaHop, _amount);

        ISigmaHop(_sigmaHop).sendCrossChainDeposit{value: hopFees}(
            _destChain,
            _to,
            _amount
        );

        // Add Wormhole Fees
        chargeFees(
            startGas,
            gasPrice,
            baseGas,
            gasTank,
            address(USDCToken),
            hopFees
        );
    }
}
