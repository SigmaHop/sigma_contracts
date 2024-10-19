// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../interfaces/ISigmaUSDCVault.sol";

contract SigmaForwarder {
    using ECDSA for bytes32;

    string public constant name = "Sigma Forwarder";
    string public constant Version = "1";
    uint16 public immutable WormHoleChainId;

    mapping(uint16 => address) public SigmaHopAddresses;
    mapping(address => uint256) public nonces;

    error ExpiredDeadline();
    error InvalidSignature();
    error InvalidArrayLengths();
    error ChainNotInSourceChains();
    error InvalidNonce();

    event TokenTransferredLocal(
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event TokenTransferredCrossChain(
        address indexed from,
        uint16 indexed destChain,
        address indexed to,
        uint256 amount
    );

    constructor(uint16 _wormHoleChainId) {
        WormHoleChainId = _wormHoleChainId;
    }

    /**
     * @notice Get the domain separator for the EIP712 signature
     * @param _chainIds The chain ids of the destination or source chains
     */
    function getDomainSeparator(
        uint16[] memory _chainIds
    ) public view returns (bytes32) {
        if (_chainIds.length == 0) {
            bytes32 DOMAIN_TYPEHASH = keccak256(
                "EIP712Domain(string name,string version,uint16 chainId,uint256 nonce)"
            );

            return
                keccak256(
                    abi.encode(
                        DOMAIN_TYPEHASH,
                        keccak256(bytes(name)),
                        keccak256(bytes(Version)),
                        WormHoleChainId,
                        nonces[msg.sender]
                    )
                );
        } else {
            bytes32 DOMAIN_TYPEHASH = keccak256(
                "EIP712Domain(string name,string version,uint16[] chainIds,uint256 nonce)"
            );

            return
                keccak256(
                    abi.encode(
                        DOMAIN_TYPEHASH,
                        keccak256(bytes(name)),
                        keccak256(bytes(Version)),
                        _chainIds,
                        nonces[msg.sender]
                    )
                );
        }
    }

    /**
     * @notice Transfer USDC token to the receiver on the same chain
     * @param SigmaUSDCVault  The address of the SigmaUSDCVault contract
     * @param _to  The address of the receiver
     * @param _amount The amount of USDC token to transfer
     * @param deadline  The deadline of the transaction
     * @param signature  The signature of the transaction
     * @param gasPrice  The gas price of the transaction
     * @param baseGas  The base gas of the transaction
     */
    function tranferTokensLocal(
        address SigmaUSDCVault,
        address _to,
        uint256 _amount,
        uint256 deadline,
        bytes memory signature,
        uint256 gasPrice,
        uint256 baseGas
    ) external {
        if (block.timestamp > deadline) revert ExpiredDeadline();

        bytes32 domainSeparator = getDomainSeparator(new uint16[](0));

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "TransferTokensLocal(address to,uint256 amount,uint256 deadline,uint256 nonce)"
                ),
                _to,
                _amount,
                deadline,
                nonces[msg.sender]
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );

        address signer = digest.recover(signature);
        if (signer == address(0) || signer != msg.sender)
            revert InvalidSignature();

        nonces[msg.sender]++;

        ISigmaUSDCVault(SigmaUSDCVault).transferToken(
            signer,
            _to,
            _amount,
            gasPrice,
            baseGas
        );

        emit TokenTransferredLocal(signer, _to, _amount);
    }

    /**
     * @notice Transfer USDC token to the receiver on the different chain
     * @param SigmaUSDCVault  The address of the SigmaUSDCVault contract
     * @param _sigmaHop  The address of the SigmaHop contract
     * @param _tos  The addresses of the receivers
     * @param _amounts The amounts of USDC token to transfer
     * @param _destChains   The destination chains
     * @param deadline  The deadline of the transaction
     * @param signature  The signature of the transaction
     * @param gasPrice  The gas price of the transaction
     * @param baseGas  The base gas of the transaction
     */
    function singleToMultiTransferToken(
        address SigmaUSDCVault,
        address _sigmaHop,
        address[] memory _tos,
        uint256[] memory _amounts,
        uint16[] memory _destChains,
        uint256 deadline,
        bytes memory signature,
        uint256 gasPrice,
        uint256 baseGas
    ) external {
        if (block.timestamp > deadline) revert ExpiredDeadline();
        if (_tos.length != _amounts.length || _tos.length != _destChains.length)
            revert InvalidArrayLengths();

        bytes32 domainSeparator = getDomainSeparator(_destChains);

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "SingleToMultiTransferToken(address sigmaHop,address[] tos,uint256[] amounts,uint16[] destChains,uint256 deadline,uint256 nonce)"
                ),
                _sigmaHop,
                _tos,
                _amounts,
                _destChains,
                deadline,
                nonces[msg.sender]
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );

        address signer = digest.recover(signature);
        if (signer == address(0) || signer != msg.sender)
            revert InvalidSignature();

        nonces[msg.sender]++;

        for (uint256 i = 0; i < _destChains.length; i++) {
            if (_destChains[i] == WormHoleChainId) {
                ISigmaUSDCVault(SigmaUSDCVault).transferToken(
                    signer,
                    _tos[i],
                    _amounts[i],
                    gasPrice,
                    baseGas
                );
                emit TokenTransferredLocal(signer, _tos[i], _amounts[i]);
            } else {
                ISigmaUSDCVault(SigmaUSDCVault).transferTokenCrossChain(
                    _sigmaHop,
                    signer,
                    _destChains[i],
                    _tos[i],
                    _amounts[i],
                    gasPrice,
                    baseGas
                );
                emit TokenTransferredCrossChain(
                    signer,
                    _destChains[i],
                    _tos[i],
                    _amounts[i]
                );
            }
        }
    }

    /**
     * @notice Transfer USDC token to the receiver on the different chain
     * @param SigmaUSDCVault  The address of the SigmaUSDCVault contract
     * @param _sigmaHop  The address of the SigmaHop contract
     * @param _to  The address of the receiver
     * @param _amounts The amounts of USDC token to transfer
     * @param _srcChains   The source chains
     * @param destChain   The destination chain
     * @param _nonces The nonces of the source chains
     * @param deadline  The deadline of the transaction
     * @param signature  The signature of the transaction
     * @param gasPrice  The gas price of the transaction
     * @param baseGas  The base gas of the transaction
     */
    function multiToSingleTransferToken(
        address SigmaUSDCVault,
        address _sigmaHop,
        address _to,
        uint256[] memory _amounts,
        uint16[] memory _srcChains,
        uint16 destChain,
        uint256[] memory _nonces,
        uint256 deadline,
        bytes memory signature,
        uint256 gasPrice,
        uint256 baseGas
    ) external {
        if (block.timestamp > deadline) revert ExpiredDeadline();
        if (_amounts.length != _srcChains.length) revert InvalidArrayLengths();

        bytes32 domainSeparator = getDomainSeparator(_srcChains);

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "MultiToSingleTransferToken(address sigmaHop,address to,uint256[] amounts,uint16[] srcChains,uint16 destChain,uint256 deadline,uint256[] nonces)"
                ),
                _sigmaHop,
                _to,
                _amounts,
                _srcChains,
                destChain,
                deadline,
                _nonces
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );

        address signer = digest.recover(signature);
        if (signer == address(0) || signer != msg.sender)
            revert InvalidSignature();

        bool isSrcChain = false;

        for (uint256 i = 0; i < _srcChains.length; i++) {
            if (_srcChains[i] == WormHoleChainId) {
                if (_nonces[i] != nonces[msg.sender]) revert InvalidNonce();
                nonces[msg.sender]++;

                ISigmaUSDCVault(SigmaUSDCVault).transferTokenCrossChain(
                    _sigmaHop,
                    signer,
                    destChain,
                    _to,
                    _amounts[i],
                    gasPrice,
                    baseGas
                );
                emit TokenTransferredCrossChain(
                    signer,
                    destChain,
                    _to,
                    _amounts[i]
                );
                isSrcChain = true;
            }
        }

        if (!isSrcChain) revert ChainNotInSourceChains();
    }
}
