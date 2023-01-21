// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FixedRateStaking is ERC20 {
    
    mapping (address => uint) public staked;
    mapping (address => uint) public stakedFromTime;

    constructor() ERC20("FixedRateStake","FRS") {
        _mint(msg.sender, 1000000000000000000);
    }

    modifier amountCheck(uint _amount){
        require(_amount > 0,"Amount should be greater than 0");
        _;
    }

    function stake(uint _amount) external  amountCheck(_amount) {        
        require(balanceOf(msg.sender) >= _amount,"Insufficient balance for tokens to be staked");
        _transfer(msg.sender, address(this), _amount);

        //if the user has already staken amount they should first claim their reward
        if (staked[msg.sender] > 0){
            claimReward();
        }
        stakedFromTime[msg.sender] = block.timestamp;
        staked[msg.sender] += _amount;
    }

    function unstake(uint _amount) external amountCheck(_amount) {
        require(staked[msg.sender] >= _amount,"You are trying to unstake more than what you staked");
        require(stakedFromTime[msg.sender] > 60,"Minimum vesting period is 60 seconds");
        claimReward();
        staked[msg.sender] -= _amount;
        stakedFromTime[msg.sender] = block.timestamp;
    }

    function claimReward() private  {
        require(staked[msg.sender] > 0 ,"No amount in stake");
        uint secondsinYear = 3.154e7;
        uint secondsStaked = block.timestamp - stakedFromTime[msg.sender];
        uint rewards = staked[msg.sender] * secondsStaked / secondsinYear;
        _mint(msg.sender, rewards);
        stakedFromTime[msg.sender] = block.timestamp;

    }

    function viewRewardAmount() public view returns(uint) {
        uint secondsinYear = 3.154e7;
        uint secondsStaked = block.timestamp - stakedFromTime[msg.sender];
        uint rewards = staked[msg.sender] * secondsStaked / secondsinYear;
        return rewards;
    }

    function viewTimeLeftToUnstake() public view returns(uint) {
        uint time = stakedFromTime[msg.sender];
        if (time <= 60){
            return (60-time);
        }
        return 0;
    }
}