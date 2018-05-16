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
    address public bountyWalletAddress = 0x281055Afc982d96fAB65b3a49cAc8b878184Cb16; // Bounty Wallet address 
    address public advisorsWalletAddress = 0x6F46CF5569AEfA1acC1009290c8E043747172d89; // Advisors Wallet address 
    address public companyReserveWalletAddress = 0x90e63c3d53E0Ea496845b7a03ec7548B70014A91; // Company Reserve Wallet address 
    address public teamWalletAddress = 0xab7c74abC0C4d48d1bdad5DCB26153FC8780f83E; // Team Wallet address 
    address public usersGrowthWalletAddress = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C; // Users Growth Wallet address 
    
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
}