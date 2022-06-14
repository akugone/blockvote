## Exercice de vote décentralisé

Présentation en video
https://www.loom.com/share/a841a9ecbecf469cb8a453f2fcd73680

# Fonctions

- ``setWorkflowStatus()``
Permet à l'admin (uniquement) de saisir le statut des sessions

RegisteringVoters ==> 0
ProposalsRegistrationStarted ==> 1
ProposalsRegistrationEnded ==> 2
VotingSessionStarted ==> 3
VotingSessionEnded ==> 4
VotesTallied ==> 5

require(_idStatus <= type(WorkflowStatus).max) permet de vérifier si le statut sélectionné existe, il sera remplacer pour un controle en front car comsommation de gas inutile

- ``addWhitelist()``

Permet a l'admin de saisir les personnes dans la liste, leur permettant par la suite de faire des propositions et de voter
L'admin est un participant comme les autres et doit donc saisir son adress pour etre whitlelisté

- ``addArrayWhitelist()``

Dans le cas ou nous avons trop de participants, nous pouvons les saisirs tous en même temps et appeller la fonction ``addWhitelist()``

-``isRegistered()``

Les participants peuvent vérifier leur statuts, voir si ils sont bien enregistré

- ``registerVoterCanPropose()``

Les personnes qui ont été intégré à la Whitelist peuvent (apres que l'admin ai setup le status vote) faire une proposition
les whitelisté peuvent faire qu'une seule proposition
J'ai utilisé les array et mapping pour l'exercice pour :
mapping => gerer les votes, descrition lié au address
array => pour stocker les propositions et les lister avec la fct ``consulteAllProposition()``

J'ai conscience que ce n'est pas le plus optimum niveau gas


- ``consulteAllProposition()``

Donne la possibilité de consulter toutes les propositions

- ``deleteAllProposal``

Donne la possibilité de vider l'array qui stocke les propositions

- ``timeToVote``

L'admin doit mettre en place le statut correspondant pour permettre aux Whitlister de voter
Il est possible de voter une seule fois

- ``getWinner``

Permet de retourner la proposition qui à le plus de vote, avec le mapping nous pourrons donc récuperer la personne a l'origine de la proposition


















