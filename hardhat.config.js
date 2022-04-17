require("@nomiclabs/hardhat-waffle");
const fs = require('fs');
const privateKey = fs.readFileSync(".secret").toString();
const projectId = "fd292b0307664618a70b3729c943ed62";

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337
    },
    /*
    mumbai: {
      url:'https://polygon-mumbai.infura.io/v3/${projectId}',
      accounts: [privateKey]
    },
    mainnet:{
      url:'https://polygon-mainnet.infura.io/v3/${projectId}',
      accounts: [privateKey]
    }
    */
  },
  solidity: "0.8.4",
};
