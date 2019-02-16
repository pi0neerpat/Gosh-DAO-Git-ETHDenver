pragma solidity ^0.5.4;

contract daogit {

    struct Repo {
        address manager;
        uint passingThreshold;
        mapping(uint => uint) votes;
        mapping(address => bool) whitelist;
    }

    mapping(bytes32 => Repo) public repo;

    event approved(
     bytes32 _repoId,
     uint _pullRequestId,
     bool passing
   );

    modifier whitelisted(bytes32 _repoId){
        require (repo[_repoId].whitelist[msg.sender],
        "Please ask the Repo Manager to whitelist you before trying again.");
        _;
    }

    modifier onlyManager(bytes32 _repoId){
        require (repo[_repoId].manager == msg.sender,
        "This function is reserved for only the Repo Manager.");
        _;
    }

    modifier doesNotExist(bytes32 _repoId){
        require (repo[_repoId].manager == address(0),
        "This repo has already been created, try again with a different Repo ID");
        _;
    }

    function createRepo(bytes32 _repoId, uint _passingThreshold) doesNotExist(_repoId) public{
        repo[_repoId].manager = msg.sender;
        repo[_repoId].passingThreshold = _passingThreshold;
    }

    function approvePullRequest(bytes32 _repoId, uint _pullRequestId) whitelisted(_repoId) public {
        repo[_repoId].votes[_pullRequestId] += 1;
        bool isPassing = repo[_repoId].votes[_pullRequestId] > repo[_repoId].passingThreshold;
        emit approved(_repoId, _pullRequestId, isPassing);
    }

    function whitelist(bytes32 _repoId, address _address) onlyManager(_repoId) public{
        repo[_repoId].whitelist[_address] = true;
    }

    function revokeWhitelist(bytes32 _repoId, address _address) onlyManager(_repoId) public{
        repo[_repoId].whitelist[_address] = false;
    }

    function isPassing(bytes32 _repoId, uint _pullRequestId) public view returns(bool){
        return (repo[_repoId].votes[_pullRequestId] > repo[_repoId].passingThreshold);
    }

    function isWhiteListed(bytes32 _repoId, address _address) public view returns(bool){
        return repo[_repoId].whitelist[_address];
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
}

}
 
