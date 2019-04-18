const assert = require('assert');
const HDWalletProvider = require("truffle-hdwallet-provider-privkey");

const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const RINKEBY_RPC = process.env.RINKEBY_RPC || "http://127.0.0.1:8545/";
assert(PRIVATE_KEY, 'PRIVATE_KEY environment variable not provided');

module.exports = {
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  networks: {
    dev: {
      host: "localhost",
      port: 8545,
      network_id: "*"
    },
    rinkeby: {
      provider: new HDWalletProvider([PRIVATE_KEY], RINKEBY_RPC),
      network_id: 4,
      skipDryRun: true
    }
  },
  compilers: {
    solc: {
      version: "^0.5.7"
    }
  }
};
