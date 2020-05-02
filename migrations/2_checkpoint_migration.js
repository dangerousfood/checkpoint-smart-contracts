const Checkpoint = artifacts.require("Checkpoint");

module.exports = function(deployer) {
  deployer.deploy(Checkpoint);
};
