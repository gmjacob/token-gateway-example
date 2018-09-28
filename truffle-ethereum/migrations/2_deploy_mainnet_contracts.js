const { writeFileSync } = require('fs')

const SpringToken = artifacts.require('SpringToken')
const Gateway = artifacts.require('Gateway')
const MaxSupply = 1000
module.exports = (deployer, network, accounts) => {
  const [_, user] = accounts
  const validator = accounts[9]
  deployer.deploy(Gateway, [validator], 3, 4).then(async () => {
    console.log('the user object:\n',user)
    const gatewayInstance = await Gateway.deployed()

    console.log(`Gateway deployed at address: ${gatewayInstance.address}`)

    const SpringTokenContract = await deployer.deploy(SpringToken, MaxSupply, gatewayInstance.address)
    const SpringTokenInstance = await SpringToken.deployed()

    console.log(`SpringToken deployed at address: ${SpringTokenInstance.address}`)
    console.log(`SpringToken transaction at hash: ${SpringTokenContract.transactionHash}`)

    await gatewayInstance.toggleToken(SpringTokenInstance.address, { from: validator })
    await SpringTokenInstance.mintToken(100)
    await SpringTokenInstance.transfer(user, 100)

    writeFileSync('../gateway_address', gatewayInstance.address)
    writeFileSync('../game_token_address', SpringTokenInstance.address)
    writeFileSync('../game_token_tx_hash', SpringTokenContract.transactionHash)
  })
}
