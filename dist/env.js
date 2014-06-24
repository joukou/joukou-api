var self;

module.exports = self = {
  getEnvironment: function() {
    switch (process.env.NODE_ENV) {
      case 'production':
        return 'production';
      case 'staging':
        return 'staging';
      default:
        return 'development';
    }
  },
  getFQDN: function() {
    switch (self.getEnvironment()) {
      case 'production':
        return 'api.joukou.com';
      case 'staging':
        return 'staging-api.joukou.com';
      default:
        return 'localhost';
    }
  },
  getServerName: function() {
    switch (self.getEnvironment()) {
      case 'production':
      case 'staging':
        return self.getFQDN();
      default:
        return require('../package.json').name;
    }
  },
  getVersion: function() {
    return require('../package.json').version;
  },
  getOrigins: function() {
    switch (self.getEnvironment()) {
      case 'production':
        return ['https://joukou.com'];
      case 'staging':
        return ['https://staging.joukou.com', 'http://localhost:2100', 'http://127.0.0.1:2100'];
      default:
        return ['http://localhost:2100', 'http://127.0.0.1:2100'];
    }
  }
};

/*
//# sourceMappingURL=env.js.map
*/
