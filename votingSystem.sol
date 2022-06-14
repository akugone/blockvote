// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";


contract Voting is Ownable {

    uint winningProposalId;

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint256 voteCount;
    }

    // on link l'adresse des votants au struct Voter
    mapping(address => Voter) public voters;
    Voter[] public votersArray;


    // on link l'adresse des proposés au struct Proposal
    mapping(address => Proposal) public proposals;
    Proposal[] public proposalsArray;

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    // on utilise enum comme un tableau
    WorkflowStatus public workflowStatus;


    // On déclare les events qui vont être trigger
    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(
        WorkflowStatus previousStatus,
        WorkflowStatus newStatus
    );
    event ProposalRegistered(uint256 proposalId);
    event Voted(address voter, uint256 indexed proposalId); // mise en place d'in indexed pour retrouver les E en front


    // on met en place un modifier pour limiter les votes et propositions au votant enregistré
    modifier onlyRegisteredVoters {
        require(voters[msg.sender].isRegistered, "deso tu n'es pas dans la whitelist");
        _;
    }

    // on met en place la function permettant de saisir le status par l'admin
    function setWorkflowStatus(WorkflowStatus _idStatus) public onlyOwner {
        // !!!! Peut etre controler la saisie en front car en cas de mauvaise saisie ==> revert de la TX
        require(_idStatus <= type(WorkflowStatus).max);

        // on set le status du worflow
        workflowStatus = _idStatus; 
    }


    // l'admin enregistre les votants dans la whitelist
    function addWhitelist(address _voterAddress) public onlyOwner {


        // on verifie que l'admin à bien ouvert la session d'enregistrement des votants
        require(workflowStatus == WorkflowStatus.RegisteringVoters , "les votes ne sont pas encore ouverts" );


        // on regarde si l'addresse du votant est déjà enregistré
        require(!voters[_voterAddress].isRegistered, "Vous etes deja enregistre");
        

        // on passe le votant enregistré en true pour indiquer qu'il est enregistré
        voters[_voterAddress].isRegistered = true;

        // on declenche l'event pour indiquer qu'il est bien enregistré
        emit VoterRegistered(_voterAddress);
        
    }


    // Dans le cas ou nous avons trop de participant nous pouvons les saisir avec un array
    function addArrayWhitelist(address[] memory _voterAddresses) public onlyOwner{

            for(uint i; i < _voterAddresses.length; i++){
                addWhitelist(_voterAddresses[i]);
            }
    }



    // Les votants peuvent consulter si ils sont bien dans la whitelist
    function isRegistered(address _voterAddress) external view returns (bool){
        return voters[_voterAddress].isRegistered;
    }


    // les inscrits et l'admin peuvent faire une proposition
    function registerVoterCanPropose(string calldata _proposition) public onlyRegisteredVoters  {

        // on verifie que l'admin a bien ouvert la session de saisie des propositions
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted , "la saisie des propositions n est pas ouverte" );

        // on converti la description en byte pour pouvoir récupérer sa longueur et ainsi vérifier qu'il n'a jamais proposé
        bytes memory tempDescription = bytes(proposals[msg.sender].description);

        // on limite a une seule proposition
        require(tempDescription.length != 0 , "vous avez deja fait une proposition");

        //On stocke la proposition dans le mapping
        proposals[msg.sender]= Proposal(_proposition, 0);

        // on permet la saisie et on stock les proposition dans le mapping
        proposalsArray.push(Proposal(_proposition, 0));

        // on trigger l'event
        emit ProposalRegistered(proposalsArray.length);

    }

    //On peut consulter les propositions de tout le monde
    function consulteAllProposition()external view returns (Proposal[] memory){
        return proposalsArray;
    }


    // On vide le tableau de proposition
    function deleteAllProposal() public onlyOwner {
        delete proposalsArray;
    }



    // on ouvre la session des votes
    function timeToVote(uint _choice) public  onlyRegisteredVoters {

        // on verifie que l'admin a bien ouvert la session de vote
        require(workflowStatus == WorkflowStatus.VotingSessionStarted , "la saisie des votes n est pas ouverte" );

        // on verifie que le choix est bien dans les propositions
        require( _choice <= proposalsArray.length, "ce choix n est pas possible");

        //on l'empeche de voter une 2 fois
        require(voters[msg.sender].hasVoted, "tu as deja vote petit macron");

        // on indique que le votant à voté
        voters[msg.sender].hasVoted = true;

        // on stock le vote dans le mapping
        voters[msg.sender].votedProposalId = _choice;

        // on incremente le nombre de vote de la proposition
        proposalsArray[_choice].voteCount++;

        // on declenche l'event pour indiquer qu'il a voté
        emit Voted(msg.sender, _choice);

    }



    function getWinner() public returns(uint){

        // on verifie que l'admin a fermé la session des votes
        require(workflowStatus == WorkflowStatus.VotingSessionEnded , "les votes ne sont pas encore clots" );

        uint storeTemp = 0;
        uint i;
        

        // gestion de l'égalité

        for(i = 0; i < proposalsArray.length ; i++ ){
            if(proposalsArray[i].voteCount > storeTemp){
                storeTemp = proposalsArray[i].voteCount;
                winningProposalId = i;
            }

        }

        return winningProposalId;
        
    }


    
    
}
