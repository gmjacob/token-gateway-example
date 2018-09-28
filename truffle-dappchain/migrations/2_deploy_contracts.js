const { writeFileSync, readFileSync } = require('fs')

const SpringTokenDappChain = artifacts.require('SpringTokenDappChain')

module.exports = (deployer, network, accounts) => {
  const gatewayAddress = readFileSync('../gateway_dappchain_address', 'utf-8')

  deployer.deploy(SpringTokenDappChain, gatewayAddress).then(async () => {
    const SpringTokenDappChainInstance = await SpringTokenDappChain.deployed()
    console.log(`SpringTokenDappChain deployed at address: ${SpringTokenDappChainInstance.address}`)
    writeFileSync('../game_token_dappchain_address', SpringTokenDappChainInstance.address)
  })
}
