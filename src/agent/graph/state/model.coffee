schema          = require( './schema')
Model           = require( '../../../riak/Model' )
Q               = require( 'q' )

GraphStateModel = Model.define(
  schema: schema
  type: 'graph_state'
  bucket: 'graph_state'
)

GraphStateModel.retrieveForGraph = ( agentKey, graphKey ) ->
  GraphStateModel.search(
    "agent_key:#{agentKey} graph_key:#{graphKey}",
    {
      firstOnly: yes
    }
  )

GraphStateModel.put = ( agentKey, graphKey, state = {}) ->
  deferred = Q.defer()
  save = ( model ) ->
    model.save()
    .then(->
      deferred.resolve(model)
    )
    .fail(deferred.reject)

  data = {
    agent_key: agentKey
    graph_key: graphKey
    x: state.x or 0
    y: state.y or 0
    scale: if state.scale is undefined or state.scale is null then 1 else state.scale
    metadata: state.metadata or {}
  }

  GraphStateModel.retrieveForGraph( agentKey, graphKey )
  .then( (model) ->
    model.setValue(data)
    save(model)
  ).fail( ->
    GraphStateModel.create(data)
    .then(save)
    .fail(deferred.reject)
  )

  return deferred.promise

GraphStateModel.afterCreate = (model) ->
  model.afterRetrieve()
  return Q.resolve(model)

GraphStateModel::beforeSave = ->

GraphStateModel::afterRetrieve = ->
  this.addSecondaryIndex( 'agent_key_bin' )
  this.addSecondaryIndex( 'graph_key_bin' )


module.exports = GraphStateModel