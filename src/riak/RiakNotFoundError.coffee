{ NotFoundError } = require( 'restify' )

module.exports = self = class extends NotFoundError
  constructor: ( @originalError, details ) ->
    super(
      restCode: 'NotFoundError'
      statusCode: 404
      message: 'Item not found'
      constructorOpt: self
    )
    this.type = details && details.type
    this.bucket = details && details.bucket
    this.key = details && details.key
    return