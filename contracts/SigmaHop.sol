// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "wormhole-solidity-sdk/WormholeRelayerSDK.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SigmaHop is CCTPSender, CCTPReceiver {
    // Gas limit for cross-chain transactions
    uint256 constant GAS_LIMIT = 250_000;

    // Address of the genesis
    address private GenesisAddress;

    // Mapping of chainId to hop address
    mapping(uint16 => address) public HopAddresses;

    /**
     * @notice Sets the SigmaHop contract.
     * @param _wormholeRelayer  The address of the wormhole relayer
     * @param _wormhole  The address of the wormhole
     * @param _circleMessageTransmitter  The address of the circle message transmitter
     * @param _circleTokenMessenger  The address of the circle token messenger
     * @param _USDC  The address of the USDC token
     */
    constructor(
        address _wormholeRelayer,
        address _wormhole,
        address _circleMessageTransmitter,
        address _circleTokenMessenger,
        address _USDC
    )
        CCTPBase(
            _wormholeRelayer,
            _wormhole,
            _circleMessageTransmitter,
            _circleTokenMessenger,
            _USDC
        )
    {
        setCCTPDomain(6, 1);
        setCCTPDomain(10005, 2);
        setCCTPDomain(10004, 6);
        GenesisAddress = msg.sender;
    }

    // Modifier to allow only genesis to call
    modifier onlyGenesis() {
        require(msg.sender == GenesisAddress, "Only genesis can call");
        _;
    }

    // Set the hop address for a chain
    function setHopAddress(
        uint16 chainId,
        address hopAddress
    ) public onlyGenesis {
        HopAddresses[chainId] = hopAddress;
    }

    /**
     * @notice Quotes the cost of a cross-chain deposit.
     * @param targetChain  The target chain
     * @return cost  The cost of the cross-chain deposit
     */
    function quoteCrossChainDeposit(
        uint16 targetChain
    ) public view returns (uint256 cost) {
        // Cost of delivering token and payload to targetChain
        (cost, ) = wormholeRelayer.quoteEVMDeliveryPrice(
            targetChain,
            0,
            GAS_LIMIT
        );
    }

    /**
     * @notice Sends a cross-chain deposit.
     * @param targetChain  The target chain
     * @param recipient  The recipient of the deposit
     * @param amount  The amount of USDC to deposit
     */
    function sendCrossChainDeposit(
        uint16 targetChain,
        address recipient,
        uint256 amount
    ) public payable {
        uint256 cost = quoteCrossChainDeposit(targetChain);
        require(msg.value == cost, "Fund requirements not met");

        address targetHopAddress = HopAddresses[targetChain];
        require(targetHopAddress != address(0), "Invalid target hop address");

        IERC20(USDC).transferFrom(msg.sender, address(this), amount);

        bytes memory payload = abi.encode(recipient);
        sendUSDCWithPayloadToEvm(
            targetChain,
            targetHopAddress, // address (on targetChain) to send token and payload to
            payload,
            0, // receiver value
            GAS_LIMIT,
            amount
        );
    }

    /**
     * Receives a payload and USDC from Wormhole Relayers
     * @param payload  The payload
     * @param amountUSDCReceived  The amount of USDC received
     * @param sourceAddress  The source address
     * @param sourceChain The source chain
     */
    function receivePayloadAndUSDC(
        bytes memory payload,
        uint256 amountUSDCReceived,
        bytes32 sourceAddress, // sourceAddress
        uint16 sourceChain, // sourceChain
        bytes32 // deliveryHash
    ) internal override onlyWormholeRelayer {
        address decodedSourceAddress = address(uint160(uint256(sourceAddress)));

        require(
            HopAddresses[sourceChain] == decodedSourceAddress,
            "Invalid source address"
        );

        address recipient = abi.decode(payload, (address));

        IERC20(USDC).transfer(recipient, amountUSDCReceived);
    }
}
