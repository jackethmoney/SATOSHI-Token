const { task } = require("hardhat/config");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
//require("hardhat-gas-reporter");

let secret = require("./secret")

task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(await account.address);
  }
});

const fs = require('fs');
const gasPriceTestnetRaw = fs.readFileSync(".gas-price-testnet.json").toString().trim();
const gasPriceTestnet = parseInt(JSON.parse(gasPriceTestnetRaw).result, 16);
if (typeof gasPriceTestnet !== 'number' || isNaN(gasPriceTestnet)) {
  throw new Error('unable to retrieve network gas price from .gas-price-testnet.json');
}

console.log("Gas price Testnet: " + gasPriceTestnet);

module.exports = {
	solidity: {
		version: "0.6.11",
		settings: {
			optimizer: {
				enabled: true,
				runs: 200,
			},
		},
	},
  defaultNetwork: "localhost",
	networks: {
		hardhat: {},

    localhost: {
      url: "http://127.0.0.1:8545",
      //accounts: [secret.key]
    },
	/*
	testnet: {
	  url: "http://localhost:4444",
	  accounts: [secret.private_key, secret.private_key2],
	  //seeds:[secret.key],
	  network_id: 31,
	  gasPrice: Math.floor(gasPriceTestnet * 1.1)
	},
	*/
    /*
		rskPublicTestnet: {
			url: secret.url,
			accounts: [secret.private_key],
      //seeds: [secret.key],
			network_id: 31,
			confirmations: 4,
			gasMultiplier: 1.25,
			//timeout: 20000, // increase if needed; 20000 is the default value
			//allowUnlimitedContractSize, //EIP170 contrtact size restriction temporal testnet workaround
		},
		rskPublicMainnet: {
			url: "https://public-node.rsk.co/",
			network_id: 30,
			//timeout: 20000, // increase if needed; 20000 is the default value
		},
    */
	},
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  /*
	mocha: {
		timeout: 800000,
		grep: "^(?!.*; using Ganache).*",
	},
	*/
  /*
	docgen: {
		path: "./docs",
		clear: true,
	},
  */
  compilers : {
    solc: {
     version: "0.6.11",
     //evmVersion: "byzantium"
    }
  },
  /*
  gasReporter: {
    currency: 'USD',
    gasPrice: 8
  }
  */
};