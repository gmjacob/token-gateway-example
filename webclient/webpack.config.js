const webpack = require('webpack')
const gameTokenJSON = require('../truffle-ethereum/build/contracts/SPRINGToken.json')
const dcGameTokenJSON = require('../truffle-dappchain/build/contracts/SPRINGTokenDappChain.json')
const gatewayJSON = require('../truffle-ethereum/build/contracts/Gateway.json')

module.exports = {
  context: __dirname + '/src',
  entry: ['regenerator-runtime/runtime', './index'],
  output: {
    path: __dirname + '/dist',
    filename: 'bundle.js'
  },
  devServer: {
    historyApiFallback: true
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader'
      }
    ]
  },
  plugins: [
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV),
      GAME_TOKEN_JSON: JSON.stringify(gameTokenJSON),
      DC_GAME_TOKEN_JSON: JSON.stringify(dcGameTokenJSON),
      GATEWAY_JSON: JSON.stringify(gatewayJSON)
    })
  ],
  optimization: {
    minimizer: []
  }
}
