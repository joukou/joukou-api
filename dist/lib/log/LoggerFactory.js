"use strict";

/**
@class joukou-api.log.LoggerFactory
@requires bunyan
@requires path
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.
 */
module.exports = new ((function() {

  /**
  @private
  @static
  @property {bunyan} bunyan
   */
  var bunyan, loggers, path;

  bunyan = require('bunyan');


  /**
  @private
  @static
  @property {path} path
   */

  path = require('path');


  /**
  @private
  @static
  @property {Object} loggers
   */

  loggers = {};


  /**
  @method constructor
   */

  function _Class() {
    if (process.env.NODE_ENV === 'production') {
      this.logLevel = bunyan.INFO;
    } else {
      this.logLevel = bunyan.TRACE;
    }
  }


  /**
  @method getLogger
  @param {Object} config
   */

  _Class.prototype.getLogger = function(config) {
    if (!loggers[config.name]) {
      return loggers[config.name] = this.createLogger(config);
    } else {
      return loggers[config.name];
    }
  };


  /**
  @method createLogger
  @param {Object} config
   */

  _Class.prototype.createLogger = function(config) {
    return bunyan.createLogger({
      name: config.name,
      streams: [
        {
          stream: process.stdout,
          level: this.logLevel
        }, {
          type: 'file',
          path: path.join(__dirname, '..', '..', 'log', "" + config.name + ".log"),
          level: this.logLevel
        }
      ]
    });
  };

  return _Class;

})());

/*
//# sourceMappingURL=LoggerFactory.js.map
*/
