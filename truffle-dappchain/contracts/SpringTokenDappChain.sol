pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "openzeppelin-solidity/contracts/AddressUtils.sol";
import "./ERC20Receiver.sol";

/* Contract class to mint tokens and transfer */
contract SPRINGTokenDappChain is StandardToken {
    using SafeMath for uint256;
    using AddressUtils for address;

    string constant public name = 'SPRING Token';
    string constant public symbol = 'SPRING';
    uint constant public decimals = 18;
    uint256 public totalSupply;
    uint256 public maxSupply;

    // Transfer Gateway contract address
    address public gateway;
    //Value of event emmitted by gateway contract on recieving ERC20 tokens
    bytes4 constant ERC20_RECEIVED = 0xbc04f0af;

    /* Contructor function to set maxSupply*/
    constructor (uint256 _maxSupply, address _gateway) public {
        gateway = _gateway;
        maxSupply = _maxSupply.mul(10**decimals);
        balances[_gateway] = totalSupply;
    }

    /**
    * @dev Called by the dAppChain Gateway contract to mint tokens that have been deposited to the Mainnet gateway
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mintToGateway(uint256 _amount) public {
        require(msg.sender == gateway, "Only the gateway contract can call this function");
        require (maxSupply >= (totalSupply.add(_amount)), "Total supply would be greater than max supply");
        totalSupply = totalSupply.add(_amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);
    }

    function onERC20Received(address _from, uint256 amount) public returns(bytes4) {
        return ERC20_RECEIVED;
    }
}