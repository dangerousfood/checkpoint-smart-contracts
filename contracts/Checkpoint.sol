pragma solidity >=0.4.21 <0.7.0;

contract Checkpoint {
  address public owner;
  mapping(address => bytes32[]) public currentMerkleBranch;
  
  struct RootData {
      //timestamp of current root
      uint timestamp;
      bytes32 prevRoot;
  }

  //address => root => previous root
  mapping(address => mapping(bytes32 => RootData)) public history;

  constructor() public {
    owner = msg.sender;
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  function rollBackCurrentMerkleBranch(bytes32 root, bytes32[] memory branch, bytes32 data) public {
      //check to ensure the root is in the history for this address
      require(history[msg.sender][root].timestamp != 0, 'Provided root does not exist in the history');
      //check prev root against
      bytes32[] memory newBranch = calculateBranch(branch, data);
      require(newBranch.length != 0 && branch[0] == root, 'Branch and data did not match provided historical root');
      currentMerkleBranch[msg.sender] = newBranch;

      //emit history rolled back event
  }

  function appendData(bytes32 data) public {
      //get previous root and timestamp (maybechange timestamp to )
      Checkpoint.RootData memory currentRootData = RootData({
          timestamp: block.timestamp,
          prevRoot: currentMerkleBranch[msg.sender][0]
      });
      //update current merkle branch
      history[msg.sender][updateCurrentMerkleBranch(msg.sender, data)] = currentRootData;
      //emit data appended event
  }

  function updateCurrentMerkleBranch(address sender, bytes32 data) private returns(bytes32) {
      //update the current branch
      currentMerkleBranch[sender] = calculateBranch(currentMerkleBranch[sender], data);
      //return the root
      return currentMerkleBranch[sender][0];
  }
  
  function calculateBranch(bytes32[] memory branch, bytes32 data) public pure returns(bytes32[] memory) {
      //TODO
  } 
  function validateData(bytes32 root, bytes32[] memory branch, bytes32 data) public pure returns(bool) {
      return (root == calculateBranch(branch, data)[0]);
  }
}