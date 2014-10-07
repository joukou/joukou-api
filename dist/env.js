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
  getHost: function() {
    switch (self.getEnvironment()) {
      case 'production':
        return 'https://api.joukou.com';
      case 'staging':
        return 'https://staging-api.joukou.com';
      default:
        return 'http://127.0.0.1:2101';
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
  },
  getOrigin: function() {
    return self.getOrigins()[0];
  },
  getGithubAuth: function() {
    var clientId, clientSecret, host, origin;
    origin = self.getOrigin();
    host = self.getHost();
    clientId = null;
    clientSecret = null;
    if (self.getEnvironment() === 'development') {
      origin += '/build/testing';
    }
    switch (self.getEnvironment()) {
      case 'production':
        clientId = "REPLACEME";
        clientSecret = "REPLACEME";
        break;
      case 'staging':
        clientId = "REPLACEME";
        clientSecret = "REPLACEME";
        break;
      default:
        clientId = "3b349282176a33f7f42e";
        clientSecret = "6befeffabcecf885ebeb8e9b95695c5a4c021461";
    }
    return {
      clientId: clientId,
      clientSecret: clientSecret,
      callbackUrl: host + "/agent/authenticate/callback",
      failedUrl: origin + "/index.html#/auth/callback/failed",
      successUrl: origin + "/index.html#/auth/callback/success"
    };
  }
};

/*
//# sourceMappingURL=env.js.map
*/
