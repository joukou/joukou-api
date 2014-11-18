Q           = require('q')
circles     = require('./default-circles')
CircleModel = require('../../circle/model')
_           = require('lodash')

create = (persona) ->
  promises = _.map(circles, (circle) ->
    circle.personas = [
      key: persona.getKey()
    ]
    CircleModel.create(
      circle
    ).then((circle) ->
      circle.save()
    )
  )
  Q.all(
    promises
  )
module.exports =
  create: create

