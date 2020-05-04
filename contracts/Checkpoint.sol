pragma solidity >=0.4.21 <0.7.0;

contract Checkpoint {
  address public owner;
  mapping(address => bytes32) public currentMerkleRoot;
  bytes32[32] zeroBranch;
  uint TREE_DEPTH = 32;

  struct RootData {
      //timestamp of current root
      uint timestamp;
      bytes32 prevRoot;
  }

  //address => root => previous root
  mapping(address => mapping(bytes32 => RootData)) public history;

  constructor() public {
    owner = msg.sender;
    for (uint i = 0; i < TREE_DEPTH - 1; i++)
        zeroBranch[i+1] = sha256(abi.encodePacked(zeroBranch[i], zeroBranch[i]));
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }
  
  function initData() public view returns (bytes32[32] memory) {
      return zeroBranch;
  }

  function rollBackCurrentMerkleRoot(bytes32 root) public {
      //check to ensure the root is in the history for this address
      require(history[msg.sender][root].timestamp != 0, 'Provided root does not exist in the history');
      currentMerkleRoot[msg.sender] = root;
      //emit history rolled back event
  }

  function updateCurrentMerkleRoot(bytes32 root) public {
      require(root != currentMerkleRoot[msg.sender], 'Root provided matches current merkle root');
      //get previous root and timestamp (maybechange timestamp to )
      Checkpoint.RootData memory currentRootData = RootData({
          timestamp: block.timestamp,
          prevRoot: currentMerkleRoot[msg.sender]
      });
      //update current merkle root
      history[msg.sender][root] = currentRootData;
      //emit root updated event
  }
  
  function calculateBranchIndex(uint256 size) private pure returns(uint128 branchIndex) {
      uint256 _size = size;
      for (uint i = 0; i < 32; i++) {
          if(size & 1 == 1) break;
          branchIndex++;
          _size /= 2;
      }
  }

  function calculateRoot(bytes32[32] memory branch, uint size) public view returns(bytes32 root) {
    uint _size = size;
    root = 0;
    for(uint h = 0; h < 32; h++){
        if (size & 1 == 1) root = sha256(abi.encodePacked(branch[h], root));
        else root = sha256(abi.encodePacked(root, zeroBranch[h]));
        _size /= 2;
    }
  }

  function calculateBranch(bytes32[32] memory branch, bytes32 data, uint size) public pure returns(bytes32[32] memory calculatedBranch) {
      calculatedBranch = branch;
      bytes32 _data = data;
      uint128 branchIndex = calculateBranchIndex(size);
      for(uint i = 0; i < 32; i++) {
          if (i < branchIndex) _data = sha256(abi.encodePacked(branch[i], _data));
          else break;
          calculatedBranch[i] = _data;
      }
  }

  function validateData(bytes32 root, bytes32[32] memory branch, bytes32 leaf, uint256 size) public pure returns(bool) {
      return (root == calculateBranch(branch, leaf, size)[0]);
  }
}