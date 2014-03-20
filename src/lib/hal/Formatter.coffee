"use strict"
###*
@class joukou-api.hal.Formatter
@requires lodash
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.

application/hal+json response formatter.
###
module.exports = ( req, res, body ) ->
  if Buffer.isBuffer( body )
    body = body.toString( 'base64' )
  else if body instanceof Error
    res.setHeader( 'Content-Type', 'application/vnd.error+json' )
    res.statusCode = body.statusCode or 500
    body = [
      logref: body.restCode
      message: body.message
      _links: res._links
    ]
  else
    res.setHeader( 'Content-Type', 'application/hal+json' )
    res.link( req.path(), 'self' )
    body._links = res._links

  data = JSON.stringify( body )

  res.setHeader( 'Content-Length', Buffer.byteLength( data ) )

  data
