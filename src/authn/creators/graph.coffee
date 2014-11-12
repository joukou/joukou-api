Q           = require('q')
GraphModel  = require('../../persona/graph/model' )

create = (persona, name = "Default Graph") ->
  deferred = Q.defer()
  GraphModel.create(
    name: name
    personas: [
      key: persona.getKey()
    ]
  )
    .then((graph) ->
      graph.save()
    )
    .then(deferred.resolve)
    .fail(deferred.reject)
  return deferred.promise


module.exports =
  create: create