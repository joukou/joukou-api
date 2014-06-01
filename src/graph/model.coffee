"use strict"

###*
In flow-based programs, the logic is defined as a *Graph*. The nodes of the
graph are *Circles*, and the edges define connections between them.

@class joukou-api/graph/Model
###

Q       = require( 'q' )
Model   = require( '../riak/Model' )
schema  = require( './schema' )

GraphModel = Model.define(
  schema: schema
  bucket: 'graph'
)

GraphModel.afterCreate = ( graph ) ->
  deferred = Q.defer()

  graph.addSecondaryIndex( 'persona' )

  deferred.resolve( graph )

  deferred.promise


module.exports = GraphModel

