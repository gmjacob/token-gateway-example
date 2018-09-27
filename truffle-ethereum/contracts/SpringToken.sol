pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "openzeppelin-solidity/contracts/AddressUtils.sol";
import "./ERC20Receiver.sol";

/* Contract class to mint tokens and transfer */
contract SPRINGToken is StandardToken {
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
    * @dev Called by the gateway contract to mint tokens that have been deposited to the Mainnet gateway
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(uint256 _amount) public onlyOwner returns (bool) {
        require (maxSupply >= (totalSupply.add(_amount)), "Total supply would be greater than max supply");
        totalSupply = totalSupply.add(_amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);
        Transfer(address(0), msg.sender, _amount);
        return true;
    }

    function onERC20Received( address _from, uint256 amount  ) public returns(bytes4) {
        return ERC20_RECEIVED;
    }

    // Additional functions for gateway interaction, influenced from Zeppelin ERC721 Impl.

    function depositToGateway(uint256 amount) external {
        safeTransferAndCall(gateway, amount);
    }

    function safeTransferAndCall(address _to, uint256 amount) public {
        transfer(_to, amount);
        require(checkAndCallSafeTransfer(msg.sender, _to, amount), "Sent to a contract which is not an ERC20 receiver");
    }

    function checkAndCallSafeTransfer(address _from, address _to, uint256 amount) internal returns (bool) {
        if (!_to.isContract()) {
            return true;
        }

        bytes4 retval = ERC20Receiver(_to).onERC20Received(_from, amount);
        return(retval == ERC20_RECEIVED);
    }

}
