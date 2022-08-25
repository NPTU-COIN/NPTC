// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + (a % b));
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * function.
 */
contract Ownable {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }

    modifier ownerOnly() {
        require(owner == msg.sender);
        _;
    }
}

/**
 * @title NPTC
 * @dev Version 0.2.0
 */
contract NPTC is Ownable {
    using SafeMath for uint256;

    string public constant name = "NPTU Coin";
    string public constant symbol = "NPTC";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    /* Broadcast when a transaction is finished to clients. */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /* Broadcast when a amount of NPTCs is destroyed to clients. */
    event Destroy(address indexed _owner, uint256 _value);

    /* Broadcast when a amount of NPTCs is removed from circulation to clients. */
    event Withdraw(uint256 _value);

    constructor(uint256 _total) {
        totalSupply = _total;
        balances[msg.sender] = totalSupply;
    }

    /**
     * @dev This function returns the balance of a specific address.
     * @param _address address : The address to be queried.
     */
    function balanceOf(address _address) public view returns (uint256 balance) {
        return balances[_address];
    }

    /**
     * @dev This function allow user to transfer NPTCs to another address.
     * @param _to address : The address to send NPTCs to.
     * @param _value uint256 : The amount to be sent.
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_value > 0, "WARNING : Transfer amount must be greater than 0.");
        require(balances[msg.sender] >= _value, "WARNING : There is not enough balance in this account."); // Check sender balance.
        require(balances[_to] + _value >= balances[_to], "ERROR : Overflow."); // Check for overflows.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approval(address _spender, uint256 _value) public returns (bool success) {
        require(_value > 0, "WARNING : Amount to be approved must be greater than 0.");
        allowed[msg.sender][_spender] = _value;
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev This function allow user to transfer NPTCs from an address to another address.
     * @param _from address : The address to send NPTCs.
     * @param _to address : The address to receive NPTCs.
     * @param _value uint256 : The amount to be transferred.
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value > 0, "WARNING : Transfer amount must be greater than 0.");
        require(balances[_from] >= _value, "WARNING : There is not enough balance in sender's account."); // Check sender balance.
        require(balances[_to] + _value >= balances[_to], "ERROR : Overflow."); // Check for overflows.
        require(allowed[_from][msg.sender] >= _value, "WARNING : There is not enough allowance in sender's account."); // Check allowance.
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev This function allows user to destroy their own NPTCs.
     * @param _value uint256 : The amount to be destroyed.
     */
    function destroy(uint256 _value) public returns (bool success) {
        require(_value > 0, "WARNING : Destroy amount must be greater than 0.");
        require(balances[msg.sender] >= _value, "WARNING : There is not enough balance in this account."); // Check sender balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Destroy(msg.sender, _value);
        return true;
    }

    /**
     * @dev This function allows the owner to remove NPTCs from total circulation and owner's account.
     * @param _value uint256 : The amount to be removed from total circulation and owner's account.
     */
    function withdraw(uint256 _value) public ownerOnly returns (bool success) {
        require(_value > 0, "WARNING : Withdraw amount must be greater than 0.");
        require(totalSupply >= _value, "WARNING : There is not enough balance in the circulation.");
        require(balances[owner] >= _value, "WARNING : There is not enough balance in owner's account."); // Check owner balance.
        totalSupply = totalSupply.sub(_value);
        balances[owner] = balances[owner].sub(_value);
        emit Withdraw(_value);
        return true;
    }
}
