const Faucet = artifacts.require('./ERC20Faucet.sol');
const SHIPToken = artifacts.require("./ERC20Tokens/SHIPToken.sol");
const ShipRinkeby = '0xa14c1d4aceb983626c066ebb3d9437e68f888b3a';
const MaxAllowance = 300000;

module.exports = function(deployer, network, accounts) {
  let deployerPromise;

  if (network.includes('rinkeby')) {
    console.log(`On Rinkeby, SHIP address is ${ShipRinkeby}`);
    deployerPromise = deployer.then(() => {
      return SHIPToken.at(ShipRinkeby);
    })
  } else {
    console.log(accounts[0].balance);
    deployerPromise = deployer.deploy(SHIPToken, accounts[0]);
  }

  deployerPromise.then((shipInstance) => {
    return Faucet.new(shipInstance.address, MaxAllowance);
  }).then((faucetInstance) => {
    console.log(`Faucet deployed @ ${faucetInstance.address}`);
  });
};