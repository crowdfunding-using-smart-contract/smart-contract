# smart-contract

## 1. Running a Local Ethereum Blockchain

To simulate an Ethereum blockchain environment on your local machine, you can use Hardhat Network, which is a local Ethereum network designed for development purposes. Here's how to start it:

- **Start Hardhat Network:** 
  - Navigate to your smart contract project directory.
  - Run the command `npx hardhat node`.
  - This command starts a local Ethereum network. It also provides you with a list of accounts and private keys for testing purposes.

## 2. Deploying Your Smart Contract Locally

The next step is to deploy your smart contract to the local Hardhat Network.

- **Write a Deployment Script:**
  - In the `scripts` folder of your Hardhat project, create a script that will deploy your smart contract.

- **Run the Deployment Script:**
  - Deploy your contract to the local network using the command `npx hardhat run scripts/your-deployment-script.js --network localhost`.

- **Record the Contract Address:**
  - After the deployment is complete, take note of the contract address. This address is crucial for interacting with the contract from your Go application.
