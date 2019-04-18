module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    dev: {
      host: "localhost",
      port: 8545,
      network_id: "*"
    },
  },
  compilers: {
    solc: {
      version: "^0.5.2"
    }
  }
};
