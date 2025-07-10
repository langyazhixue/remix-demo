// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Ballot {
    // 创建投票人结构体
    // 投票
    event voteSuccess(string);
    struct Voter {
        uint256 weight; // 权重
        bool voted; // 是否投票
        address delegate; //委托人地址
        uint256 vote; // 主题id
    }
    event votes(Voter);
    // 创建主题结构体
    struct Proposal {
        string name; // 主题名称
        uint256 voteCount; // 票数
    }

    //  主持人地址 也就是投票发起人地址
    address public chairperson;

    // 创建投票人集合
    mapping(address => Voter) public voters;
    // 主题集合
    Proposal[] public proposals;

    // 构造函数中保持主持人地址
    constructor(string[] memory proposalNames) {
        chairperson = msg.sender;
        // 其余的结构数据会给与默认值
        voters[chairperson].weight = 1;
        for (uint256 i = 0; i < proposalNames.length; i++) {
            Proposal memory proposalItem = Proposal(proposalNames[i], 0);
            proposals.push(proposalItem);
        }
    }

    // 返回主题集合
    function proposalList() public view returns (Proposal[] memory) {
        return proposals;
    }

    // 给某些地址赋予选票
    function giveRightToVote(address[] memory voteAddressList) public {
        // 只有算有着可以调用方法
        require(msg.sender == chairperson, "only ower can give right");
        for (uint256 i = 0; i < voteAddressList.length; i++) {
            // 如果该地址已经投过票 不处理，未投过票 赋予权
            emit votes(voters[voteAddressList[i]]);
            if (voters[voteAddressList[i]].weight == 0 && !voters[voteAddressList[i]].voted && voters[voteAddressList[i]].delegate == address(0) && voters[voteAddressList[i]].vote == 0) {
                voters[voteAddressList[i]] = Voter({
                    weight: 0,
                    voted: false,
                    delegate: address(0),
                    vote: 0
                });
            }
            if (!voters[voteAddressList[i]].voted) {
                voters[voteAddressList[i]].weight = 1;
            }
        }
    }

    // 将投票权委托给别人
    function delegate(address to) public {
        //  获取委托人信息
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "you already voted");
        require(msg.sender != to, "self delegate is no allow");
        //  循环判断 委托人不能为空 也不能为自己
        while (voters[to].delegate != address(0)) {
            //
            to = voters[to].delegate;
            require(to == msg.sender, "Found loop in delegete");
        }
        // 将委托人信息修改 投票状态 和 委托人信息
        sender.voted = true;
        sender.delegate = to;
        // 获取被委托人信息
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // 被委托人如果投票直接将票数相加
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    // 投票

    function vote(uint256 idx) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = idx;
        proposals[idx].voteCount += sender.weight;
         emit voteSuccess(unicode"投票成功");
    }

    // 计算投票结果
     function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }
}

// 主持人 0x6975476f2ee985D9D04a180ce090651BaB645a5C
// 投票人 ['0x667D0F43494b6B4fDd3527F0dF3eC565F0727acF','0x92e2aE86d117F67c85d019d2718C9EBEac766093','0x71B75978708057e6D238A8FEBFD4680a48a52F5e']
// 候选人 ['张三','李四','王五']
// contractAddress: 0xaa6F99AF642429986255841C127EdBDBBAbD9448
// 第一步，合约部署，部署时候传入 ['张三','李四','王五']proposalNames 主题地址
// 第二步，主持人执行 getRightToVote, 初始化投票人地址 3个。。。
// 第三步，张三投票给0
// 第四步，李四授权王五投票，王五投票给
