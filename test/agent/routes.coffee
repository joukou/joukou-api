###*
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

assert      = require( 'assert' )
chai        = require( 'chai' )
should      = chai.should()
chai.use( require( 'chai-http' ) )

AgentModel  = require( '../../dist/agent/Model' )
server      = require( '../../dist/server' )
riakpbc     = require( '../../dist/riak/pbc' )

###
Attempt to monkey-patch application/hal+json parsing. Appears to cause empty
response body, futher investigation needed. For now server is configured to
send application/json responses.

superagent  = require( 'chai-http/node_modules/superagent' )
superagent.parse[ 'application/hal+json' ] = ( res, done ) ->
  res.text = ''
  res.setEncoding( 'utf8' )
  res.on( 'data', ( chunk ) -> res.text += chunk )
  res.on( 'end', ->
    try
      done( null, JSON.parse( res.text ) )
    catch err
      done( err )
  )
###