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
    require(status == WorkflowStatus.RegisteringVoters, "not the time to add voters");
    require(!voters[_toWhitelist].isRegistered, "voter is already registered");
    
    voters[_toWhitelist].isRegistered = true;
    emit VoterRegistered(_toWhitelist);
  }

  function startProposalSession() public onlyOwner {
    require(status == WorkflowStatus.RegisteringVoters, "not the time to iniate proposal registering session");
   status = WorkflowStatus.ProposalsRegistrationStarted;
   emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
   emit ProposalsRegistrationStarted(" proposal registration session is started");
  }

  function endProposalSession() public onlyOwner {
    require(status == WorkflowStatus.ProposalsRegistrationStarted, "registering proposal is not in progress");
    status = WorkflowStatus.ProposalsRegistrationEnded;
    emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted , WorkflowStatus.ProposalsRegistrationEnded);
    emit ProposalsRegistrationEnded(" proposal registration session is ended");
  }

  function startVotingSession() public onlyOwner {
    require(status == WorkflowStatus.ProposalsRegistrationEnded, "not the time to iniate voting session");
    status = WorkflowStatus.VotingSessionStarted;
    emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded , WorkflowStatus.VotingSessionStarted);
    emit ProposalsRegistrationStarted("voting session is started");
  }

  function endVotingSession() public onlyOwner {
    require(status == WorkflowStatus.VotingSessionStarted, "voting session is not in process");
    status = WorkflowStatus.VotingSessionEnded;
    emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted , WorkflowStatus.VotingSessionEnded);
    emit VotingSessionEnded("voting session is ended");
  }

  function createProposal(string memory _proposal) public {
    require(status == WorkflowStatus.ProposalsRegistrationStarted, "it's not time to register proposal");
    require(voters[msg.sender].isRegistered == true, "address is not permitted to submit proposal");
    require(voters[msg.sender].hasSubmittedProposal != true, "voter has already submitted proposal");
    
    proposalsArray.push(Proposal({
      description: _proposal,
      voteCount : 0
    }));
    voters[msg.sender].hasSubmittedProposal = true;
  }

  function vote(uint _proposalId) public {
    require(status == WorkflowStatus.VotingSessionStarted, "it's not time for voting");
    require(voters[msg.sender].isRegistered == true, "user is not permitted to vote");
    require(voters[msg.sender].hasVoted != true, "user has already voted");

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

}


  //Unique function for starting and ending session
  // function modifySession(bool _session, string _command)private onlyOwner{
  //     if(_command == "start"){
  //       _session = true;
  //     }
  //     if(_command =="end"){
  //       _session = false;
  //     }
  // }


// Un smart contract de vote peut être simple ou complexe, selon les exigences des élections que vous souhaitez soutenir. Le vote peut porter sur un petit nombre de propositions (ou de candidats) présélectionnées, ou sur un nombre potentiellement important de propositions suggérées de manière dynamique par les électeurs eux-mêmes.

// Dans ce cadres, vous allez écrire un smart contract de vote pour une petite organisation. Les électeurs, que l'organisation connaît tous, sont inscrits sur une liste blanche (whitelist) grâce à leur adresse Ethereum, peuvent soumettre de nouvelles propositions lors d'une session d'enregistrement des propositions, et peuvent voter sur les propositions lors de la session de vote.

// Le vote n'est pas secret ; chaque électeur peut voir les votes des autres.

// Le gagnant est déterminé à la majorité simple ; la proposition qui obtient le plus de voix l'emporte.

// Le processus de vote : 

// Voici le déroulement de l'ensemble du processus de vote :

// L'administrateur du vote enregistre une liste blanche d'électeurs identifiés par leur adresse Ethereum.
// L'administrateur du vote commence la session d'enregistrement de la proposition.
// Les électeurs inscrits sont autorisés à enregistrer leurs propositions pendant que la session d'enregistrement est active.
// L'administrateur de vote met fin à la session d'enregistrement des propositions.
// L'administrateur du vote commence la session de vote.
// Les électeurs inscrits votent pour leurs propositions préférées.
// L'administrateur du vote met fin à la session de vote.
// L'administrateur du vote comptabilise les votes.
// Tout le monde peut vérifier les derniers détails de la proposition gagnante.
// Les recommandations et exigences :

// Votre smart contract doit s’appeler “Voting”. 
// Votre smart contract doit utiliser la version 0.6.11 du compilateur.
// L’administrateur est celui qui va déployer le smart contract. 
// Votre smart contract doit définir les structures de données suivantes : 
// struct Voter {
// bool isRegistered;
// bool hasVoted;
// uint votedProposalId;
// }

// struct Proposal {
// string description;
// uint voteCount;
// }
// Votre smart contract doit définir une énumération qui gère les différents états d’un vote
// enum WorkflowStatus {
// RegisteringVoters,
// ProposalsRegistrationStarted,
// ProposalsRegistrationEnded,
// VotingSessionStarted,
// VotingSessionEnded,
// VotesTallied
// }
// Votre smart contract doit définir un uint “winningProposalId” qui représente l’id du gagnant.
// Votre smart contract doit importer le smart contract la librairie “Ownable” d’OpenZepplin.
// Votre smart contract doit définir les événements suivants : 
// event VoterRegistered(address voterAddress);
// event ProposalsRegistrationStarted();
// event ProposalsRegistrationEnded();
// event ProposalRegistered(uint proposalId);
// event VotingSessionStarted();
// event VotingSessionEnded();
// event Voted (address voter, uint proposalId);
// event VotesTallied();
// event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus
// newStatus);