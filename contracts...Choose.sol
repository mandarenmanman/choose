// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title 选择
 * @dev 防疫措施公投,基于六度关系理论
 * @author historyblock.org
 */
contract Choose {
    uint256 init = 0;
    uint256 public neutrality = 0; //中立
    uint256 public open = 0; //开放
    uint256 public dynamicZeroing = 0; //动态清零
    mapping(address => address[]) people; //只能邀请六人投票
    mapping(address => uint256) votingCheck; //每人只能投一票,将投票结果放入
    address owner; // 定义owner变量
    address[] a6;

    event whitelistCheckEvent(
        address indexed higher, //合约调用人的邀请人
        address indexed owner, //合约调用人的地址
        bool wCheck //是否被邀请
    );

    event inviteEvent(
        address indexed owner, //合约调用人的地址
        address indexed higher, //合约调用人的邀请人
        uint256 calltag //1 邀请用户成功  2 你的邀请人不在白名单中  3 已达到最大邀请人
    );

    // 构造函数
    constructor() {
        owner = msg.sender; // 在部署合约的时候，将owner设置为部署者的地址
    }

    /**
     * 邀请用户投票，由合约账户建立起点后，被邀请账户可继续邀请6人
     */
    function invite(address invited, address higher) public returns (uint256) {
        if (init == 0 && owner == msg.sender) {
            a6 = new address[](0);
            a6.push(invited);
            people[msg.sender] = a6;
            init = 1;
            emit inviteEvent(msg.sender, higher, 1);
            return a6.length;
        } else {
            if (whitelistCheck(higher) == false) {
                emit inviteEvent(msg.sender, higher, 2);
                revert("Please contact 66ccff@historyblock.org");
            } else {
                a6 = people[msg.sender];
                a6.push(invited);
                //邀请的人不能超过6个
                if (a6.length <= 6) {
                    people[msg.sender] = a6;
                    emit inviteEvent(msg.sender, higher, 1);
                    return a6.length;
                }
            }
            emit inviteEvent(msg.sender, higher, 3);
            revert("The number of invitations has exceeded 6 people");
        }
    }

    /**
     * 投票函数
     */
    function voting(uint256 choose, address higher) public returns (uint256) {
        //检查值是否合法
        if (!(choose == 1 || choose == 2 || choose == 3)) {
            revert("Please enter the correct value");
        }

        //检查是否被邀请
        if (whitelistCheck(higher) == false) {
            revert("Please contact 66ccff@historyblock.org");
        }

        //检查是否已经投票过
        if (votingCheck[msg.sender] != 0) {
            revert("Already voted");
        }

        votingCheck[msg.sender] = choose;

        if (choose == 1) {
            dynamicZeroing = dynamicZeroing + 1; //0 动态清零
            return dynamicZeroing;
        } else if (choose == 2) {
            open = open + 1; //开放
            return open;
        } else if (choose == 3) {
            neutrality = neutrality + 1; //中立
            return neutrality;
        }

        return 0;
    }

    /**
     * @dev 返回账户对应投票结果
     * @return value of 'number'
     */
    function getVoting(address adr) public view returns (uint256) {
        return votingCheck[adr];
    }

    /**
     * @dev 返回对应账户邀请人
     */
    function getPeople(address adr)
        public
        view
        returns (address[] memory _array)
    {
        _array = people[adr];
    }

    //邀请检查
    function whitelistCheck(address higher) public returns (bool) {
        a6 = people[higher];
        if (a6.length == 0) {
            emit whitelistCheckEvent(higher, msg.sender, false);
            return false;
        } else {
            for (uint256 i = 0; i < a6.length; i++) {
                //被邀请过
                if (a6[i] == msg.sender) {
                    emit whitelistCheckEvent(higher, msg.sender, true);
                    return true;
                }
            }
            emit whitelistCheckEvent(higher, msg.sender, false);
            return false;
        }
    }
}
