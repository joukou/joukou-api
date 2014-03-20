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
argv    = require( 'yargs' ).argv
async   = require( 'async' )
riakpbc = require( '../../dist/riak/pbc' )

riakpbc.getKeys(
  type: argv.type or 'default'
  bucket: argv.bucket
, ( err, reply ) ->
  if err
    console.log( err )
    process.exit( 1 )
    return

  unless reply.keys
    console.log( 'zero keys found in ' + (argv.type or 'default') + '/' + argv.bucket)
    process.exit(0)
    return

  async.eachLimit( reply.keys, 4, ( key, next ) ->
    riakpbc.del(
      type: argv.type or 'default'
      bucket: argv.bucket
      key: key
    , ( err, reply ) ->
      if err
        console.log( "Error deleting #{argv.type or 'default'}/#{argv.bucket}/#{key}: ", err )
        next( err )
      else
        console.log( "Deleted #{argv.type or 'default'}/#{argv.bucket}/#{key}" )
        next()
    )
  , ( err ) ->
    if err
      process.exit( 1 )
    else
      process.exit( 0 )
  )
)