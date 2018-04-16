const Sum = artifacts.require("SumsToFifteen");

module.exports = function(deployer) {
	deployer.deploy(Sum);
};