
Model   = require( '../../riak/Model' )
schema  = require( './schema' )

CircleModel = Model.define(
  type: 'persona'
  bucket: 'persona'
  schema: schema
)

module.exports = CircleModel
