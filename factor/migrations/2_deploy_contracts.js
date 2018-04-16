const Verf = artifacts.require("Verifier");

module.exports = function(deployer) {
	deployer.deploy(Verf);
};
