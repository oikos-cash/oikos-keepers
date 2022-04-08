pragma solidity ^0.8.0;

import "./Math.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./SafeERC20.sol";

import "./IRewardDistributionRecipient.sol";

contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    // oUSD/BNB V2
    // https://bscscan.com/address/0xcb947258d38f45fffb53e7930f38cb8b6dc69d4f#code 
    // DRV/drv V2
    //0x0a462ae6613ca1ae4dabc933889354821cc88cd8
    // https://bscscan.com/address/0x0a462ae6613ca1ae4dabc933889354821cc88cd8 
    // ?? 
    // https://bscscan.com/address/0x2Ee9c2cE331Feb7ae40Ab2D5667dfde09a80F99E 
    IERC20 public uni = IERC20(0x8517c11E0459eec933391476eAe41613e9E52A1d);
    IERC20 public drv = IERC20(0x4aC8B09860519d5A17B6ad8c86603aa2f07860d6);

    uint256 public _totalSupply;
    mapping(address => uint256) public _balances;
    mapping(address => bool) public _staked;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public keepers;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    struct Staker {
        uint id;
        address account;
        uint balance;
        bool isBanned;
    }

    mapping(address => Staker) public stakers;
    address[] public stakersIdx;

    function addStaker(address account, uint balance) internal  {
        stakersIdx.push(account);
        uint id = stakersIdx.length -1;
        stakers[account] = Staker(id, account, balance, false);
    }

    function editStaker(address account, uint balance, bool isBanned) internal  {
        Staker storage staker = stakers[account];
        staker.balance = balance;
        staker.isBanned = isBanned;
    }

    function banDelinquentAccounts() external onlyKeeper {
        uint counter;
        for (uint i=0; i<stakersIdx.length; i++) {
            address account = stakersIdx[i];
            
            Staker storage staker = stakers[account];

            uint balance = staker.balance;
            bool isBanned = staker.isBanned;

            if (!isBanned && balance > 0) {
                bool isDelinquent = (uni.balanceOf(account) < balance);
                if (isDelinquent) {
                    editStaker(account, balance, true);
                    counter ++;
                }
            }
        }
        uint rewards = (2000 ether) * counter;
        drv.safeTransfer(msg.sender, rewards);
    }

 
    function isKeeper(address account) public view returns(bool) {
        bool flag = keepers[account];
        return flag;
    }
    
    modifier onlyKeeper {
        bool flag = isKeeper(msg.sender);
        require(flag, "Only keepers may perform this action");
        _;
    }

    function isStaker(address account) public view returns(bool) {
        if(stakersIdx.length == 0) return false;
        return (stakers[account].account == account);
    }

    function getStaker(address account) public view returns(Staker memory){
        require(isStaker(account), "Not staked");
        Staker memory staker = stakers[account];
        return staker;
    } 

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public  returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view  returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public  returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public  returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal  {
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal  {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function stake(uint256 amount) virtual public {
        require(!_staked[msg.sender], "Already staked");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        _staked[msg.sender] = true;
         addStaker(msg.sender, _balances[msg.sender]);
    }
    
    function withdraw(uint256 amount) virtual public {
        require(_staked[msg.sender], "Not staking");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _staked[msg.sender] = false;
         editStaker(msg.sender, _balances[msg.sender], stakers[msg.sender].isBanned);
    }
}

contract CakePool is LPTokenWrapper, IRewardDistributionRecipient {
    uint256 public constant DURATION = 365 days;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
 
        return rewardPerTokenStored +
                    lastTimeRewardApplicable() - lastUpdateTime * rewardRate * 1e18 / totalSupply();
    }

    function earned(address account) public view returns (uint256) {
        uint val = balanceOf(account) * ( (rewardPerToken() - userRewardPerTokenPaid[account]) / 1e18 ) + rewards[account];
           
        return val;
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount) override public isContract updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        require(!stakers[msg.sender].isBanned, "Banned account");

        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) override public updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public isContract updateReward(msg.sender) {
        require(!stakers[msg.sender].isBanned, "Banned account");
        uint256 reward = earned(msg.sender);
        rewards[msg.sender] = 0;
        drv.transfer(msg.sender, reward);
        emit RewardPaid(msg.sender, reward);
    }

    function notifyRewardAmount(uint256 reward)
        override virtual external 
        onlyRewardDistribution
        updateReward(address(0))
    {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward / (DURATION);
        } else {
            uint256 remaining = periodFinish - (block.timestamp);
            uint256 leftover = remaining * (rewardRate);
            rewardRate = reward+ (leftover) / (DURATION);
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + (DURATION);
        emit RewardAdded(reward);
    }

    function unbanAccount(address account) external onlyOwner {
        editStaker(account, 0, false);
        uint staked = _balances[account];
        _totalSupply = _totalSupply - (staked);
        _balances[account] = 0;
        _staked[account] = false;
        rewards[account] = 0;
        userRewardPerTokenPaid[account] = 0;
    }    

    function editKeeper(address account, bool flag) external onlyOwner {
        keepers[account] = flag;
    }    

    modifier isContract() {
        require(msg.sender == tx.origin, "contracts not allowed");  
        _;
    }
}
