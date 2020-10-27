//"SPDX-License-Identifier: MIT"
pragma solidity >= 0.6 .11;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";


contract Voting is Ownable {

  uint public winningProposalId;
  string public winningProposal;
  Proposal[] public proposalsArray;
  mapping(address => Voter) public voters;

  struct Voter {
    bool isRegistered;
    bool hasVoted;
    uint votedProposalId;
    bool hasSubmittedProposal;
  }

  struct Proposal {
    string description;
    uint voteCount;
  }

  enum WorkflowStatus {
    RegisteringVoters,
    ProposalsRegistrationStarted,
    ProposalsRegistrationEnded,
    VotingSessionStarted,
    VotingSessionEnded,
    VotesTallied
  }

  WorkflowStatus status = WorkflowStatus.RegisteringVoters;

  event VoterRegistered(address voterAddress);
  event ProposalsRegistrationStarted(string text);
  event ProposalsRegistrationEnded(string text);
  event ProposalRegistered(uint proposalId);
  event VotingSessionStarted(string text);
  event VotingSessionEnded(string text);
  event Voted(address voter, uint proposalId);
  event VotesTallied();
  event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);


  function whitelist(address _toWhitelist) public onlyOwner {
    require(status == WorkflowStatus.RegisteringVoters, "wrong workflow");
    require(!voters[_toWhitelist].isRegistered, "already registered");
    
    voters[_toWhitelist].isRegistered = true;
    emit VoterRegistered(_toWhitelist);
  }

  function startProposalSession() public onlyOwner {
    require(status == WorkflowStatus.RegisteringVoters, "wrong workflow");
   status = WorkflowStatus.ProposalsRegistrationStarted;
   emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
   emit ProposalsRegistrationStarted(" proposal registration started");
  }

  function endProposalSession() public onlyOwner {
    require(status == WorkflowStatus.ProposalsRegistrationStarted, "wrong workflow");
    status = WorkflowStatus.ProposalsRegistrationEnded;
    emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted , WorkflowStatus.ProposalsRegistrationEnded);
    emit ProposalsRegistrationEnded(" proposal registration ended");
  }

  function startVotingSession() public onlyOwner {
    require(status == WorkflowStatus.ProposalsRegistrationEnded, "Wrong workflow");
    status = WorkflowStatus.VotingSessionStarted;
    emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded , WorkflowStatus.VotingSessionStarted);
    emit ProposalsRegistrationStarted("voting started");
  }

  function endVotingSession() public onlyOwner {
    require(status == WorkflowStatus.VotingSessionStarted, "Wrong workflow");
    status = WorkflowStatus.VotingSessionEnded;
    emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted , WorkflowStatus.VotingSessionEnded);
    emit VotingSessionEnded("voting ended");
  }

  function createProposal(string memory _proposal) public {
    require(status == WorkflowStatus.ProposalsRegistrationStarted, "not time to register proposal");
    require(voters[msg.sender].isRegistered == true, "address not allowed");
    require(voters[msg.sender].hasSubmittedProposal != true, "proposal already submitted");
    
    proposalsArray.push(Proposal({
      description: _proposal,
      voteCount : 0
    }));
    voters[msg.sender].hasSubmittedProposal = true;
  }

  function vote(uint _proposalId) public {
    require(status == WorkflowStatus.VotingSessionStarted, "it's not time for voting");
    require(voters[msg.sender].isRegistered == true, "user is not permitted to vote");
    require(voters[msg.sender].hasVoted != true, "already voted");

    proposalsArray[_proposalId].voteCount++;
    voters[msg.sender].hasVoted = true;
    
    emit  Voted(msg.sender, _proposalId);
  }
  

  function tallyVotes() public onlyOwner returns (uint, string memory){
      require(status == WorkflowStatus.VotingSessionEnded);
      status = WorkflowStatus.VotesTallied;
    uint winningVoteCount = 0;
    for(uint p=0; p < proposalsArray.length; p++){
      if(proposalsArray[p].voteCount > winningVoteCount){
        winningVoteCount = proposalsArray[p].voteCount;
        winningProposal = proposalsArray[p].description;
        winningProposalId = p;
      }
    }
    return( winningProposalId, winningProposal );
  }

