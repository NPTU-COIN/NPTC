// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract SafeMath {
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

contract NPTC is SafeMath {
    string public constant name = "NPTC";
    string public constant symbol = "NPTC";
    uint8 public constant decimals = 18;
    uint256 public totalSupply_;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval( address indexed _owner, address indexed _spender, uint256 _value);

    constructor(uint256 _total) {
        totalSupply_ = _total;
        balances[msg.sender] = totalSupply_;
    }

    function balanceOf(address _address) public view returns (uint256) {
        return balances[_address];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        if (_value <= 0) revert();
        if (balances[msg.sender] < _value) revert();
        if (balances[_to] + _value < balances[_to]) revert();
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approval(address _spender, uint256 _value) public returns (bool) {
        if (_value <= 0) revert();
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if (_value <= 0) revert();
        if (balances[_from] < _value) revert();
        if (balances[_to] + _value < balances[_to]) revert();
        if (allowed[_from][msg.sender] < _value) revert();
        balances[_from] = SafeMath.sub(balances[_from], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        allowed[_from][msg.sender] = SafeMath.sub(
            allowed[_from][msg.sender],
            _value
        );
        emit Transfer(_from, _to, _value);
        return true;
    }
}
