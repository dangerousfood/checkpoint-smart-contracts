const truffleAssert = require('truffle-assertions');
const Checkpoint = artifacts.require("../contracts/Checkpoint.sol");

contract("Checkpoint Tests", async accounts => {
    var contract;

    beforeEach(function() {
       return Checkpoint.new()
       .then(function(instance) {
          contract = instance;
       });
    });

    it("Assert that the previous merkle root is eliminated", async () => {
        let instance = contract;
        // console.log(web3)
        prevRootExpected = web3.utils.randomHex(32);
        currRootExpected = web3.utils.randomHex(32);
        await instance.updateCurrentMerkleRoot(prevRootExpected, {from: accounts[0]});
        await instance.updateCurrentMerkleRoot(currRootExpected, {from: accounts[0]});
        currRootActual = await instance.getCurrentMerkleRoot.call(accounts[0]);
        prevRootActual = await instance.getPreviousMerkleRoot.call(accounts[0]);

        assert.equal(currRootExpected, currRootActual, "Current root is incorrect");
        assert.equal(prevRootExpected, prevRootActual, "Pevious root is incorrect");
      });
      it("Assert that the updateCurrentMerkleRoot emits a corrrect event", async () => {
        let instance = contract
        root = web3.utils.randomHex(32);
        tx = await instance.updateCurrentMerkleRoot(root, {from: accounts[0]});
        truffleAssert.eventEmitted(tx, 'RootUpdated', (ev) => {
            msg = 'expected value did not match the actual value in RootUpdated event'
            assert.equal(accounts[0], ev.sender, 'sender: ' + msg);
            assert.equal(root, ev.currentRoot, 'currentRoot: ' + msg);
            assert.equal(0, ev.prevRoot, 'prevRoot: ' + msg);
            return true;
        });
      });
      it("Assert that rollBackCurrentMerkleRoot replaces root", async () => {
        let instance = contract;
        rootExpected = web3.utils.randomHex(32);
        await instance.updateCurrentMerkleRoot(rootExpected, {from: accounts[0]});
        await instance.updateCurrentMerkleRoot(web3.utils.randomHex(32), {from: accounts[0]});
        await instance.rollBackCurrentMerkleRoot(rootExpected, {from: accounts[0]});
        rootActual = await instance.getCurrentMerkleRoot.call(accounts[0]);

        assert.equal(rootExpected, rootActual, "Current root is incorrect");
      });
      it("Assert that rollBackCurrentMerkleRoot emits the correct values in HistoryRolledBack event", async () => {
        let instance = contract;
        rootExpected = web3.utils.randomHex(32);
        await instance.updateCurrentMerkleRoot(rootExpected, {from: accounts[0]});
        await instance.updateCurrentMerkleRoot(web3.utils.randomHex(32), {from: accounts[0]});
        tx = await instance.rollBackCurrentMerkleRoot(rootExpected, {from: accounts[0]});

        truffleAssert.eventEmitted(tx, 'HistoryRolledBack', (ev) => {
            msg = 'expected value did not match the actual value in HistoryRolledBack event'
            assert.equal(accounts[0], ev.sender, 'sender: ' + msg);
            assert.equal(rootExpected, ev.currentRoot, 'currentRoot: ' + msg);
            assert.equal(0, ev.prevRoot, 'prevRoot: ' + msg);
            return true;
        });
      });
    it("Assert that rollBackCurrentMerkleRoot will not rollback to an incorrect history", async () => {
        let instance = contract;
        root = web3.utils.randomHex(32);
        await instance.updateCurrentMerkleRoot(root, {from: accounts[0]});
        tx = instance.rollBackCurrentMerkleRoot(web3.utils.randomHex(32), {from: accounts[0]});
        truffleAssert.reverts(tx);
      });
    });