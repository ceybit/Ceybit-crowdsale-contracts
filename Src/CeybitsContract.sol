pragma solidity ^0.4.23;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}
 

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}


/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock {
  using SafeERC20 for ERC20Basic;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint256 public releaseTime;

  constructor(
    ERC20Basic _token,
    address _beneficiary,
    uint256 _releaseTime
  )
    public
  {
    // solium-disable-next-line security/no-block-members
    require(_releaseTime > now);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public {
    // solium-disable-next-line security/no-block-members
    require(now >= releaseTime);

    uint256 amount = token.balanceOf(this);
    require(amount > 0);

    token.safeTransfer(beneficiary, amount);
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();
  
  address public crowdsaleContract;
  
  bool crowdsaleContractAdded;
  bool public paused = false;

    
  /**
     * @dev Add distribution smart contract address
    */
    function addCrowdsaleContract(address _contract) external {
        require(_contract != address(0));
        require(crowdsaleContractAdded == false);

        crowdsaleContract = _contract;
        crowdsaleContractAdded = true;
  }
    
  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
      if(msg.sender != crowdsaleContract) {
            require(!paused);
        }
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}


/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}


/**
 * @title FreezableToken
 */
contract FreezableToken is StandardToken, Ownable {
    mapping (address => bool) public frozenAccounts;
    event FrozenFunds(address target, bool frozen);

    function freezeAccount(address target) public onlyOwner {
        frozenAccounts[target] = true;
        emit FrozenFunds(target, true);
    }

    function unFreezeAccount(address target) public onlyOwner {
        frozenAccounts[target] = false;
        emit FrozenFunds(target, false);
    }

    function frozen(address _target) constant public returns (bool){
        return frozenAccounts[_target];
    }

    // @dev Limit token transfer if _sender is frozen.
    modifier canTransfer(address _sender) {
        require(!frozenAccounts[_sender]);
        _;
    }

    function transfer(address _to, uint256 _value) public canTransfer(msg.sender) returns (bool success) {
        // Call StandardToken.transfer()
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public canTransfer(_from) returns (bool success) {
        // Call StandardToken.transferForm()
        return super.transferFrom(_from, _to, _value);
    }
}


/**
 * @title Ceybits Token smart contract
 */
contract CeybitsToken is FreezableToken, PausableToken {
    string public constant name = "\"Ceybits\" Utility Token";
    string public constant symbol = "CYBT";
    uint8 public constant decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 2100000000 ether; // 2.1 billion total supply

    // ETH wallet addresses
    address public bountyWalletAddress = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C; // Bounty Wallet address 
    address public advisorsWalletAddress = 0x6F46CF5569AEfA1acC1009290c8E043747172d89; // Advisors Wallet address 
    address public companyReserveWalletAddress = 0x90e63c3d53E0Ea496845b7a03ec7548B70014A91; // Company Reserve Wallet address 
    address public teamWalletAddress = 0xab7c74abC0C4d48d1bdad5DCB26153FC8780f83E; // Team Wallet address 
    address public usersGrowthWalletAddress = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C; // Users Growth Wallet address 
    
    /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier onlyBountyWallet() {
      require(msg.sender == bountyWalletAddress);
      _;
    }

    // Locked tokens contract addresses
    address public teamLockedTokensAddress;
    address public companyReserveLockedTokensAddress;
    address public usersGrowthLockedTokensAddress;
    
    // Lock times
    uint256 internal teamTokensLockTime = uint256(now) + 365 days; // Lock for 1 year
    uint256 internal companyReserveTokensLockTime = uint256(now) + 365 days; // Lock for 1 year
    uint256 internal usersGrowthReserveTokensLockTime = uint256(now) + 180 days; // Lock for 6 months
    
    // Tokens distribution
    uint256 internal bountyTokensAmount; // 2% of tokens for bounty
    uint256 internal advisorsTokensAmount; // 2% of tokens for advisors 
    uint256 internal companyReserveTokensAmount; // 9% of tokens for company reserve
    uint256 internal teamTokensAmount; // 15% of tokens for team
    uint256 internal usersGrowthTokensAmount; // 25% of tokens for users growth pool
    uint256 internal crowdsaleTokensAmount; // 47% of tokens for users growth pool

    event TokenTimeLockEnabled(address _contractAddress, uint256 _tokensAmount, uint256 _releaseTime, address _beneficiary);
        
    /**
     * @dev Constructor
     */
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        
        // Calculate amount for each wallets
        bountyTokensAmount = (totalSupply_.mul(2)).div(100);  // 2% from total supply
        advisorsTokensAmount = (totalSupply_.mul(2)).div(100); // 2% from total supply
        companyReserveTokensAmount = (totalSupply_.mul(9)).div(100);  // 9% from total supply
        teamTokensAmount = (totalSupply_.mul(15)).div(100); // 15% from total supply
        usersGrowthTokensAmount = (totalSupply_.mul(25)).div(100);  // 25% from total supply
        crowdsaleTokensAmount = (totalSupply_.mul(47)).div(100); // 47% from total supply
        
        // Create timelock contract for team, company reserve and users growht pool addresses
        TokenTimelock teamLockedContract = new TokenTimelock(this, teamWalletAddress, teamTokensLockTime);
        TokenTimelock companyReserveLockedContract = new TokenTimelock(this, companyReserveWalletAddress, companyReserveTokensLockTime);
        TokenTimelock usersGrowthLockedContract = new TokenTimelock(this, usersGrowthWalletAddress, usersGrowthReserveTokensLockTime);
        
        // Save addresses of timelock contracts
        teamLockedTokensAddress = address(teamLockedContract);
        companyReserveLockedTokensAddress = address(companyReserveLockedContract);
        usersGrowthLockedTokensAddress = address(usersGrowthLockedContract);
          
        // Distributing tokens 
        balances[bountyWalletAddress] = balances[bountyWalletAddress].add(bountyTokensAmount);
        balances[advisorsWalletAddress] = balances[advisorsWalletAddress].add(advisorsTokensAmount);
        balances[companyReserveLockedTokensAddress] = balances[companyReserveWalletAddress].add(companyReserveTokensAmount);
        balances[teamLockedTokensAddress] = balances[teamWalletAddress].add(teamTokensAmount);
        balances[usersGrowthLockedTokensAddress] = balances[usersGrowthWalletAddress].add(usersGrowthTokensAmount);
        balances[msg.sender] = balances[msg.sender].add(crowdsaleTokensAmount);
        
        // Events
        emit TokenTimeLockEnabled(teamLockedTokensAddress, teamTokensAmount, teamTokensLockTime, teamWalletAddress); 
        emit TokenTimeLockEnabled(companyReserveLockedTokensAddress, companyReserveTokensAmount, companyReserveTokensLockTime, companyReserveWalletAddress);  
        emit TokenTimeLockEnabled(usersGrowthLockedTokensAddress, usersGrowthTokensAmount, usersGrowthReserveTokensLockTime, usersGrowthWalletAddress);  

        emit Transfer(0x0, bountyWalletAddress, bountyTokensAmount);
        emit Transfer(0x0, advisorsWalletAddress, advisorsTokensAmount);
        emit Transfer(0x0, companyReserveWalletAddress, companyReserveTokensAmount);
        emit Transfer(0x0, teamWalletAddress, teamTokensAmount);
        emit Transfer(0x0, usersGrowthWalletAddress, usersGrowthTokensAmount);
        emit Transfer(0x0, msg.sender, crowdsaleTokensAmount);
    }

    function sendTokens(address[] _addresses, uint256[] _amountTokens) public onlyBountyWallet returns(bool success) {
        require(_addresses.length > 0);
        require(_amountTokens.length > 0);
        require(_addresses.length  == _amountTokens.length);
        uint x = 0;

        while(x < _addresses.length){
          super.transfer(_addresses[x], _amountTokens[x]);
          x++;
        }

        return true;
    }
}


/**
 * @title Ceybits project crowdsale smart contract
 */
contract CeybitsICO is Ownable {
    using SafeMath for uint256;

    uint256 public rate = 100; // 1 ETH = 100 CYBT
    uint256 public weiRaised; 
    uint256 public tokensSold; 
    
    uint256 public stage = 0;

    CeybitsToken public token; // The token which being sold
    
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event StageStarted(uint256 tokens, uint256 startDate);
    event StageFinished(uint256 time);
    event EthClaimed(uint256 amount);
    event RateChanges(uint256 oldRate, uint256 newRate);

    
    struct Ico {
        uint256 tokens;    // Tokens in crowdsale
        uint256 startDate; // Date when crowsale will be starting, after its starting that property will be the 0
        bool finished;
    }

    Ico public ICO;


    /**
     * @dev Constructor
    */
    constructor(address _tokenAddress) Ownable() public {
        require(_tokenAddress != 0x0);
        
        token = CeybitsToken(_tokenAddress);
        token.addCrowdsaleContract(this);
    }
    
    /**
     * @dev Start crowdsale phase
    */
    function startPhase(uint256 _tokens, uint256 _startDate) public onlyOwner {
        require(_tokens <= token.balanceOf(this));
        require(_startDate >= now);
        
        if(stage == 0){
            ICO = Ico(_tokens, _startDate, false);
            stage = stage.add(1);
        } else {
            require(ICO.finished);
            ICO = Ico(_tokens, _startDate, false);
            stage = stage.add(1);
        }

        emit StageStarted(_tokens, _startDate);
    }

    /**
     * @dev fallback function
    */
    function () external payable {
        buyTokens(msg.sender);
    }
    
    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * @param _beneficiary Address performing the token purchase
    */
    function buyTokens(address _beneficiary) public payable {     
        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);
    
        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);
        require(ICO.tokens >= tokens); 
    
        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase( msg.sender, _beneficiary, weiAmount, tokens);
    
        _updatePurchasingState(tokens);
    
        _forwardFunds();
        _postValidatePurchase(weiAmount);
    }
  
    /** 
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param _weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
    */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        uint256 tokens =  _weiAmount.mul(rate);
        tokens = tokens.add(_calculateBonus(tokens));

        return tokens;
    }
    
    /**
     * @dev Calulate bonus size for each stage
     * @param _amount Amount, which we need to calculate
    */
    function _calculateBonus(uint256 _amount) internal view returns(uint256) {        
        if (stage == 1) {
            return _amount.mul(65).div(100);  // 65% bonus for private sale
        } 
        else if (stage == 2) {
            return  _amount.mul(45).div(100);  // 45% bonus for pre-sale
        }
        else if (stage == 3) {
            return  _amount.mul(23).div(200);  // 11.5% bonus for ICO 1st phase
        }

        return 0;
    }

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
    */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view {
        require(ICO.startDate <= now);
        require(ICO.finished == false);
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
    }
  
    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
     * @param _beneficiary Address receiving the tokens
     * @param _tokenAmount Number of tokens to be purchased
    */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
    }
  
    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
     * @param _beneficiary Address performing the token purchase
     * @param _tokenAmount Number of tokens to be emitted
    */
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        token.transfer(_beneficiary, _tokenAmount);
    }
    
    /** 
     * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
     * @param _tokens Tokens which are purchased
    */
    function _updatePurchasingState(uint256 _tokens) internal {
        tokensSold = tokensSold.add(_tokens);
        ICO.tokens = ICO.tokens.sub(_tokens);

        if(ICO.tokens == 0) {
            ICO.finished = true;
            emit StageFinished(now);
        }
    }
  
    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
    */
    function _forwardFunds() internal {
        owner.transfer(msg.value);
        emit EthClaimed(msg.value);
    }
    
    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
     * @param _weiAmount Value in wei involved in the purchase
    */
    function _postValidatePurchase(uint256 _weiAmount) internal {      
        weiRaised = weiRaised.add(_weiAmount);
    }

    function _changeRate(uint256 _newRate) public onlyOwner {
      require(_newRate != 0);
      emit RateChanges(rate, _newRate);

      rate = _newRate;
    }
    
    /**
     * @dev Get crowdsale current status (string)
    */
    function crowdSaleStatus() public constant returns(string) {
        if (0 == stage) {
            return "ICO does not start yet.";
        }
        else if (1 == stage) {
            return "Private sale";
        }
        else if(2 == stage) {
            return "Pre sale";
        }
        else if (3 == stage) {
            return "ICO first phase";
        }
        else if (4 == stage) {
            return "ICO second phase";
        }

        return "Crowdsale finished!";
    }
}