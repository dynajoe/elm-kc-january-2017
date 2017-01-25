const Path = require('path')
const Express = require('express')
const Webpack = require('webpack')
const WebpackDevMiddleware = require('webpack-dev-middleware')
const WebpackHotMiddleware = require('webpack-hot-middleware')
const WebpackConfig = require('./webpack.config')

const initialize = (app) => {
   const compiler = Webpack(WebpackConfig)

   app.use(WebpackDevMiddleware(compiler, {
      publicPath: '/',
      hot: true,
      quiet: false,
      noInfo: true,
      stats: {
         colors: true,
      },
   }))

   app.use(WebpackHotMiddleware(compiler, {
      log: console.log,
   }))

   app.use('/', Express.static(Path.join(__dirname, './public')))
}

module.exports = {
   initialize: initialize,
}