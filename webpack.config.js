const
  { resolve } = require('path')

module.exports = (_, argv) => ({
  'context':  resolve(__dirname, 'src/client') ,

  'entry': './index.js',

  'output': {
    'path': resolve(__dirname, 'public/'),
    'filename': 'app.js'
  },

  'module': {
    'rules':[
      {
        'test': /\.elm$/,
        'exclude': [ /elm-stuff/, /node_modules/ ],
        'use': 'elm-webpack-loader'
      }
    ]
  }
})
