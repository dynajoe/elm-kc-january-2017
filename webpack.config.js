var Webpack = require('webpack')
var Path = require('path')

module.exports = {
   entry: [
      'webpack-hot-middleware/client',
      './src/index.js',
   ],

   output: {
      filename: '[name].js',
      path: '/',
   },

   resolve: {
      modulesDirectories: ['node_modules'],
      extensions: ['', '.js', '.elmproj']
   },

   plugins: [
      new Webpack.HotModuleReplacementPlugin(),
   ],

   module: {
      loaders: [{
         test: /\.elmproj$/,
         exclude: [ /elm-stuff/, /node_modules/ ],
         loaders: [
            'elm-hot',
            'elm-webpack-project'
         ],
      }, {
         test: /.js$/,
         exclude: /(node_modules|\.min\.|elm-stuff)/,
         loaders: ['react-hot', 'babel'],
      }],

      noParse: /\.elmproj$/,
   },

   devServer: {
      inline: true,
      hot: true,
      stats: 'errors-only',
   },
};
