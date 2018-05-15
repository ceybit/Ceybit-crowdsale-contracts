pragma solidity ^0.4.23;


import "./Ownable.sol";

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