// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Voting{
    //defining structure with multiple candidate variables
    struct Candidate{
        bool supported;
        address id;
        uint voteCount;
        string candidateName;
    }

    event Registered( address candidateId, uint256 candidateNum, string candidateName);
    event Supported ( address voter, address candidate);
    event Voted( address voter, address candidate);

    //Giving ref using mapping

    mapping( address => bool) public voters;

    mapping (uint => Candidate) public candidates;

    address ecadmin;

    uint public candidatesCount;
    uint256 public startTime;
    uint256 public stopTime;


    constructor(){
        ecadmin = msg.sender;
    }

    function addCandidate(string memory _name) public payable{
        require(msg.value ==0.1 ether, "Appropraite ethere not exist");
        //is candidate already registered.

        candidatesCount++;
        candidates[candidatesCount] = Candidate(false, msg.sender,0,_name);
        emit Registered (msg.sender, candidatesCount, _name);

    }

    function supportCandidate(uint256 _candidateId) external {
        require(candidates[_candidateId].id != address(0x00), "Not Registered");
        require(candidates[_candidateId].id != msg.sender, "Self Support not allowed");
        require(candidates[_candidateId].supported ==false, "Already supported" );
        candidates[_candidateId].supported = true;

        emit Supported(msg.sender, candidates[_candidateId].id);

    }

    modifier ecAdminOnly(){
        require(msg.sender == ecadmin, "EC admin only operation");
        _;
    }

    function setStop(uint256 num) external ecAdminOnly{
    require(num > block.timestamp && num > startTime, "Stop at later time");
    stopTime = num;
    }

    function setStart(uint256 num) external ecAdminOnly{
    require(num >= block.timestamp, "Start at earlier time");
    startTime = num;
    }

    function vote(uint _candidateID) public{
        require(block.timestamp > startTime, "Not in voting time");
        require(block.timestamp <= stopTime, "Voting time over");
        require(voters[msg.sender] == false, "Already voted");
        require(candidates[_candidateID].id != address(0x00), "Not Registered");
        require(candidates[_candidateID].supported == true, "Dont vote not supported");

        voters[msg.sender] = true;
        candidates[_candidateID].voteCount++;
        emit Voted(msg.sender, candidates[_candidateID].id);
    }

    function getResults() public view returns (Candidate memory candidate){
        require(block.timestamp >= stopTime, "Voting time not over");
        uint256 c;
        uint256 max = 0;
        for(uint i = 1; i <= candidatesCount; i++){
            if(candidates[i].voteCount > max){
                max = candidates[i].voteCount;
                c = i;
            }
        }
        return candidates[c];
    }

}   