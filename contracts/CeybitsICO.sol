pragma solidity ^0.4.23;

import "./CeybitsToken.sol";

/**
 * @title Ceybits project crowdsale smart contract
 */
contract CeybitsICO is Ownable {
    using SafeMath for uint256;

    uint256 public rate = 20000; // 1 ETH = 100 CYBT
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
            return  _amount.mul(25).div(200);  // 12.5% bonus for ICO 1st phase
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