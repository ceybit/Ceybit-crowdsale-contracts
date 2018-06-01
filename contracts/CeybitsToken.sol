pragma solidity ^0.4.23;

import "./Ownable.sol";
import "./PausableToken.sol";
import "./FreezableToken.sol";
import "./TokenTimeLock.sol";

/**
 * @title Ceybits Token smart contract
 */
contract CeybitsToken is FreezableToken, PausableToken {
    string public constant name = "\"Ceybits\" Utility Token";
    string public constant symbol = "CYBT";
    uint8 public constant decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 2100000000 ether; // 2.1 billion total supply

    // ETH wallet addresses
    address public bountyWalletAddress = 0x30452A32d7B76Fa4841E1fe5b153A3Ae89404029; // Bounty Wallet address 
    address public advisorsWalletAddress = 0x90EE688f43Dab43675d709e56964A898d4d11C9B; // Advisors Wallet address 
    address public foundationWalletAddress = 0xd3b13Ee32F724709400eE5de8c0208383Ea378d3; // Company Reserve Wallet address 
    address public teamWalletAddress = 0xC46C2bE90e97a5F0F457F22826a3eE462875d192; // Team Wallet address 
    address public usersGrowthWalletAddress = 0x58B828eeb546220d843f9cdDe6F233B91f3f49F7; // Users Growth Wallet address 
    
    /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier onlyBountyWallet() {
      require(msg.sender == bountyWalletAddress);
      _;
    }

    // Locked tokens contract addresses
    address public teamLockedTokensAddress;
    address public foundationLockedTokensAddress;
    address public usersGrowthLockedTokensAddress;
    
    // Lock times
    uint256 internal teamTokensLockTime = uint256(now) + 365 days; // Lock for 1 year
    uint256 internal foundationTokensLockTime = uint256(now) + 365 days; // Lock for 1 year
    uint256 internal usersGrowthReserveTokensLockTime = uint256(now) + 180 days; // Lock for 6 months
    
    // Tokens distribution
    uint256 internal bountyTokensAmount; // 2% of tokens for bounty
    uint256 internal advisorsTokensAmount; // 2% of tokens for advisors 
    uint256 internal foundationTokensAmount; // 9% of tokens for company reserve
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
        foundationTokensAmount = (totalSupply_.mul(9)).div(100);  // 9% from total supply
        teamTokensAmount = (totalSupply_.mul(15)).div(100); // 15% from total supply
        usersGrowthTokensAmount = (totalSupply_.mul(25)).div(100);  // 25% from total supply
        crowdsaleTokensAmount = (totalSupply_.mul(47)).div(100); // 47% from total supply
        
        // Create timelock contract for team, company reserve and users growht pool addresses
        TokenTimelock teamLockedContract = new TokenTimelock(this, teamWalletAddress, teamTokensLockTime);
        TokenTimelock foundationLockedContract = new TokenTimelock(this, foundationWalletAddress, foundationTokensLockTime);
        TokenTimelock usersGrowthLockedContract = new TokenTimelock(this, usersGrowthWalletAddress, usersGrowthReserveTokensLockTime);
        
        // Save addresses of timelock contracts
        teamLockedTokensAddress = address(teamLockedContract);
        foundationLockedTokensAddress = address(foundationLockedContract);
        usersGrowthLockedTokensAddress = address(usersGrowthLockedContract);
          
        // Distributing tokens 
        balances[bountyWalletAddress] = balances[bountyWalletAddress].add(bountyTokensAmount);
        balances[advisorsWalletAddress] = balances[advisorsWalletAddress].add(advisorsTokensAmount);
        balances[foundationLockedTokensAddress] = balances[foundationWalletAddress].add(foundationTokensAmount);
        balances[teamLockedTokensAddress] = balances[teamWalletAddress].add(teamTokensAmount);
        balances[usersGrowthLockedTokensAddress] = balances[usersGrowthWalletAddress].add(usersGrowthTokensAmount);
        balances[msg.sender] = balances[msg.sender].add(crowdsaleTokensAmount);
        
        // Events
        emit TokenTimeLockEnabled(teamLockedTokensAddress, teamTokensAmount, teamTokensLockTime, teamWalletAddress); 
        emit TokenTimeLockEnabled(foundationLockedTokensAddress, foundationTokensAmount, foundationTokensLockTime, foundationWalletAddress);  
        emit TokenTimeLockEnabled(usersGrowthLockedTokensAddress, usersGrowthTokensAmount, usersGrowthReserveTokensLockTime, usersGrowthWalletAddress);  

        emit Transfer(0x0, bountyWalletAddress, bountyTokensAmount);
        emit Transfer(0x0, advisorsWalletAddress, advisorsTokensAmount);
        emit Transfer(0x0, foundationWalletAddress, foundationTokensAmount);
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
