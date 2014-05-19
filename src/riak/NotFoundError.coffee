###*
@class joukou-api/riak/NotFoundError
###

module.exports = class extends Error

  ###*
  @constructor
  ###
  constructor: ( message ) ->
    super( message )
    @notFound = true
    return