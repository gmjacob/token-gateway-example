pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./ERC20Receiver.sol";
import "./ValidatorManagerContract.sol";


contract Gateway is ERC20Receiver, ValidatorManagerContract {

    using SafeMath for uint256;

    struct Balance {
        mapping(address => uint256) erc20;
    }

    mapping (address => Balance) balances;

    event ERC20Received(address from, uint256 amount, address contractAddress);

    enum TokenKind {
        ERC20
    }

    /**
    * Event to log the withdrawal of a token from the Gateway.
    * @param owner Address of the entity that made the withdrawal.
    * @param kind The type of token withdrawn (ERC20/ERC721/ETH).
    * @param contractAddress Address of token contract the token belong to.
    * @param value For ERC721 this is the uid of the token, for ETH/ERC20 this is the amount.
    */
    event TokenWithdrawn(address indexed owner, TokenKind kind, address contractAddress, uint256 value);

    constructor (address[] _validators, uint8 _threshold_num, uint8 _threshold_denom)
        public ValidatorManagerContract(_validators, _threshold_num, _threshold_denom) {
    }

    function depositERC20(address from, uint256 amount) private {
        balances[from].erc20[msg.sender] = balances[from].erc20[msg.sender].add(amount);
    }

    // Withdrawal functions
    function withdrawERC20(uint256 amount, bytes sig, address contractAddress)
        external
        isVerifiedByValidator(amount, contractAddress, sig)
    {
        balances[msg.sender].erc20[contractAddress] = balances[msg.sender].erc20[contractAddress].sub(amount);
        ERC20(contractAddress).transfer(msg.sender, amount);
        emit TokenWithdrawn(msg.sender, TokenKind.ERC20, contractAddress, amount);
    }

    // Approve and Deposit function for 2-step deposits
    // Requires first to have called `approve` on the specified ERC20 contract
    function depositERC20(uint256 amount, address contractAddress) external {
        ERC20(contractAddress).transferFrom(msg.sender, address(this), amount);
        balances[msg.sender].erc20[contractAddress] = balances[msg.sender].erc20[contractAddress].add(amount);
        emit ERC20Received(msg.sender, amount, contractAddress);
    }

    // Receiver functions for 1-step deposits to the gateway

    function onERC20Received(address _from, uint256 amount)
        public
        returns (bytes4)
    {
        require(allowedTokens[msg.sender], "Not a valid token");
        depositERC20(_from, amount);
        emit ERC20Received(_from, amount, msg.sender);
        return ERC20_RECEIVED;
    }

    // Returns all the ERC20 you own
    function getERC20(address owner, address contractAddress) external view returns (uint256) {
        return balances[owner].erc20[contractAddress];
    }

}
