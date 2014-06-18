"use strict"

###*
In flow-based programs, the logic is defined as a *Graph*. The nodes of the
graph are *Circles* (aka nodes), and the edges define connections between them.

@class joukou-api/graph/Model
@extends joukou-api/riak/Model
@requires q
@requires joukou-api/graph/schema
@requires restify
###

Q                 = require( 'q' )
Model             = require( '../riak/Model' )
schema            = require( './schema' )
{ ConflictError } = require( 'restify' )

GraphModel = Model.define(
  type: 'graph'
  schema: schema
  bucket: 'graph'
)

GraphModel::addProcess = ( { component, metadata } ) ->
  key = uuid.v4()
  
  @getValue().processes[ key ] =
    component: component
    metadata: metadata

  Q.fcall( -> key )

GraphModel::getProcess = ( key ) ->
  Q.fcall( => @getValue().processes[ key ] )

GraphModel::getProcesses = ->
  Q.fcall( => @getValue().processes )

GraphModel::addConnection = ( { data, src, tgt, metadata } ) ->
  deferred = Q.defer()

  if @_hasConnection( { src: src, tgt: tgt } )
    process.nextTick( =>
      deferred.reject( new ConflictError( "Graph #{@getKey()} already has an identical connection between the source and the target." ) )
    )
  else
    connection =
      key: uuid.v4()
      data: data
      src: src
      tgt: tgt
      metadata: metadata

    @getValue().connections.push( connection )

    process.nextTick( -> deferred.resolve( connection ) )

  deferred

GraphModel::_hasConnection = ( { src, tgt } ) ->
  _.some( @getValue().connections, ( connection ) ->
    _.isEqual( connection.src, src ) and _.isEqual( connection.tgt, tgt )
  )

GraphModel::hasConnection = ( options ) ->
  Q.fcall( => @_hasConnection( options ) )

GraphModel::getConnections = ->
  Q.fcall( => @getValue().connections )


module.exports = GraphModel