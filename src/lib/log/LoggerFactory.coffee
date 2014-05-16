"use strict"
###*
@class joukou-api/log/LoggerFactory
@requires bunyan
@requires path
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###
module.exports = new class

  ###*
  @private
  @static
  @property {bunyan} bunyan
  ###
  bunyan  = require( 'bunyan' )

  ###*
  @private
  @static
  @property {path} path
  ###
  path    = require( 'path' )

  ###*
  @private
  @static
  @property {Object} loggers
  ###
  loggers = {}

  ###*
  @method constructor
  ###
  constructor: ->
    if process.env.NODE_ENV is 'production'
      @logLevel = bunyan.INFO
    else
      @logLevel = bunyan.TRACE

  ###*
  @method getLogger
  @param {Object} config
  ###
  getLogger: ( config ) ->
    unless loggers[ config.name ]
      loggers[ config.name ] = @createLogger( config )
    else
      loggers[ config.name ]

  ###*
  @method createLogger
  @param {Object} config
  ###
  createLogger: ( config ) ->
    bunyan.createLogger(
      name: config.name
      streams: [
        {
          stream: process.stdout
          level: @logLevel
        }
        {
          type: 'file'
          path: path.join( __dirname, '..', '..', 'log', "#{config.name}.log" )
          level: @logLevel
        }
      ]
    )