###*
Copyright 2014 Joukou Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
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