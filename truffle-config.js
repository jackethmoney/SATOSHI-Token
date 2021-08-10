var HDWalletProvider = require('@truffle/hdwallet-provider')

const fs = require('fs');
var mnemonic = fs.readFileSync(".secret").toString().trim();
if (!mnemonic || mnemonic.split(' ').length !== 12) {
  throw new Error('unable to retrieve mnemonic from .secret');
}
var publicTestnetNode = 'https://public-node.testnet.rsk.co/'

const gasPriceTestnetRaw = fs.readFileSync(".gas-price-testnet.json").toString().trim();
const gasPriceTestnet = parseInt(JSON.parse(gasPriceTestnetRaw).result, 16);
if (typeof gasPriceTestnet !== 'number' || isNaN(gasPriceTestnet)) {
  throw new Error('unable to retrieve network gas price from .gas-price-testnet.json');
}
console.log("Gas price Testnet: " + gasPriceTestnet);

module.exports = {
  networks: {
    rskTestnet: {
      provider: () => new HDWalletProvider(mnemonic, publicTestnetNode),
      network_id: 31,
      gasPrice: Math.floor(gasPriceTestnet * 1.1),
      //networkCheckTimeout: 1e9
    }
  },
  compilers : {
     solc: {
      version: "0.6.11",
      //evmVersion: "byzantium"
     }
  }
  mocha: {},
}