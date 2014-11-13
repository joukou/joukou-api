robot         = require( '../../authn/creators/robot' )
authn         = require( '../../authn' )
PersonaModel  = require('../model')
restify       = require( 'restify' )
uuid          = require( 'node-uuid' )

module.exports = self =

  registerRoutes: ( server ) ->
    server.post( '/persona/:personaKey/robot', authn.authenticate, self.create )
    return

  create: ( req, res, next ) ->
    PersonaModel.retrieve(req.params.personaKey)
    .then((persona) ->
      robot.create(persona)
      .then((robot) ->
        value = robot.getValue()
        value.jwt_token = uuid.v4()
        robot.setValue(value)
        robot.save()
        .then( ->
          represntation = {
            name: value.name
            key: robot.getKey()
            access_token: authn.Bearer.generate(robot, value.jwt_token)
          }
          if req.accepts("application/hal+json")
            represntation["_embedded"] =
              'joukou:agent': {
                name: value.name
                _links:
                  self: "/agent/#{robot.getKey()}"
              }
          res.send(200, represntation)
        )
      ).fail( (err) ->
        res.send(503, err)
      )
    )
    .fail(->
      next(new restify.UnauthorizedError())
    )