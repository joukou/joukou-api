#!/usr/bin/env coffee

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