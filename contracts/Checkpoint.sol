pragma solidity >=0.4.21 <0.7.0;

contract Checkpoint {
  address public owner;
  mapping(address => bytes32) public currentMerkleRoot;
  bytes32[32] zeroBranch;

  struct RootData {
      //timestamp of current root
      uint timestamp;
      bytes32 prevRoot;
  }

  //address => root => previous root
  mapping(address => mapping(bytes32 => RootData)) public history;

  constructor() public {
    owner = msg.sender;
    bytes32 zeroData;
    zeroBranch = calculateBranch(zeroBranch, zeroData);
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  function rollBackCurrentMerkleRoot(bytes32 root) public {
      //check to ensure the root is in the history for this address
      require(history[msg.sender][root].timestamp != 0, 'Provided root does not exist in the history');
      currentMerkleRoot[msg.sender] = root;
      //emit history rolled back event
  }

  function updateCurrentMerkleRoot(bytes32 root) public {
      //get previous root and timestamp (maybechange timestamp to )
      Checkpoint.RootData memory currentRootData = RootData({
          timestamp: block.timestamp,
          prevRoot: currentMerkleRoot[msg.sender]
      });
      //update current merkle root
      history[msg.sender][root] = currentRootData;
      //emit root updated event
  }
  
  function calculateBranch(bytes32[32] memory branch, bytes32 data) public pure returns(bytes32[32] memory) {
      //TODO
  }

  function validateData(bytes32 root, bytes32[32] memory branch, bytes32 data) public pure returns(bool) {
      return (root == calculateBranch(branch, data)[0]);
  }
}