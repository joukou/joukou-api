"use strict"

###*
Simple wrapper to pre-configure the restify-cors-middleware module.
@module joukou-api/cors
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

cors  = require( 'restify-cors-middleware' )
env   = require( './env' )

module.exports = cors(
  origins: env.getOrigins()
  allowHeaders: [
    'authorization'
    'accept',
    'accept-version',
    'content-type',
    'request-id',
    'origin',
    'x-api-version',
    'x-request-id'
  ]
  exposeHeaders: [
    'api-version',
    'content-length',
    'content-md5',
    'content-type',
    'date',
    'request-id',
    'response-time'
  ]
)