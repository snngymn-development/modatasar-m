const path = require('path')
module.exports = {
  resolver: {
    extraNodeModules: {
      '@core': path.resolve(__dirname, '../../packages/core/src'),
      '@shared': path.resolve(__dirname, '../../packages/shared/src'),
    },
  },
  watchFolders: [path.resolve(__dirname, '../../packages')],
}

