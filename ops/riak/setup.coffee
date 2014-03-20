#!/usr/bin/env coffee
###
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

###*
Initial setup for Basho Riak 2.0; e.g. custom bucket types or search schemas.

@author Isaac Johnston <isaac.johnston@joukou.com>
###

_           = require( 'lodash' )
fs          = require( 'fs' )
path        = require( 'path' )
request     = require( 'request' )
riak_admin  = require( 'riak-admin' )( cmd: '/Users/isaac/bin/riak-2.0.0beta1/bin/riak-admin' )

riakuri = 'http://localhost:8098/'

fs.readFile( path.join( __dirname, '..', '..', 'dist', 'agent', 'schema.xml' ), ( err, data ) ->
  if err
    console.log(err)
    process.exit(1)
    return

  request(
    uri: riakuri + 'search/schema/agent'
    method: 'PUT'
    headers:
      'Content-Type': 'application/xml'
    body: data
  , ( err, response ) ->
    if err
      console.log(err)
      process.exit(1)
      return

    statusCodeClass = Math.floor( response.statusCode / 100 ) * 100

    if statusCodeClass is 400 or statusCodeClass is 500
      console.log(response.body)
      process.exit(1)
      return

    request(
      uri: riakuri + 'search/index/agent'
      method: 'PUT'
      json:
        schema: 'agent'
    , ( err, response ) ->
      if err
        console.log(err)
        process.exit(1)
        return

      statusCodeClass = Math.floor( response.statusCode / 100 ) * 100

      if statusCodeClass is 400 or statusCodeClass is 500
        console.log(response.body)
        process.exit(1)
        return

      riak_admin.bucketType.list().then( ( bucketTypes ) ->
        if _.some( bucketTypes, ( type ) -> type.name is 'agent' )
          return

        riak_admin.bucketType.create( 'agent', props: { search_index: 'agent', allow_mult: false } ).then( ->
          riak_admin.bucketType.activate( 'agent' ).then( ->
            console.log( 'created and activated agent bucket type' )
          ).fail( ( err ) ->
            console.log( err )
            process.exit(1)
          )
        ).fail( ( err ) ->
          console.log( err )
          process.exit(1)
        )
      )
    )
  )
)

