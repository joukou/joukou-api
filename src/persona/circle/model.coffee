
Model   = require( '../../riak/Model' )
schema  = require( './schema' )
Q       = require( 'q' )

CircleModel = Model.define(
  type: 'circle'
  bucket: 'circle'
  schema: schema
)

CircleModel.afterCreate = (circle) ->
  circle.afterRetrieve()
  return Q.resolve(circle)

CircleModel.retrieveByPersona = ( key ) ->
  CircleModel.search( "personas.key:#{key}", 'personas.key' )

CircleModel::beforeSave = ->

CircleModel::afterRetrieve = ->
  this.addSecondaryIndex( 'name_bin' )
  this.addSecondaryIndex( 'personas.key_bin' )

module.exports = CircleModel
