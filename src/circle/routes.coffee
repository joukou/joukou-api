CircleModel  = require( './model' )
PersonaModel = require( '../persona/model' )
_            = require( 'lodash' )
Q            = require( 'q' )
authn        = require( '../authn' )

module.exports = self =

  registerRoutes: ( server ) ->
    server.get( '/circle', authn.authenticate, self.index )
    server.get( '/circle/:key', authn.authenticate, self.retrieve )
    server.del( '/circle/:key', authn.authenticate, self.remove )
    server.put( '/circle/', authn.authenticate, self.create )
    server.get( '/circle/search/:name', authn.authenticate, self.search )
    return

  index: ( req, res, next ) ->

  retrieve: ( req, res, next ) ->


  remove: ( req, res, next ) ->

  create: ( req, res, next ) ->

  search: ( req, res, next ) ->
    PersonaModel.getForAgent(req.user)
    .then((personas) ->
      promises = _.map(personas, (persona) ->
        like = CircleModel.likeQuery("name", req.params.name)
        CircleModel.search(
          """
          personas.key:#{persona.getKey()} AND
          #{like}
          """
        )
      )
      Q.all(
        promises
      )
      .then((circles) ->
        representation = {}
        representation.result = _.map(_.flatten(circles, true), (circle) ->
          value = circle.getValue()
          return {
            key: circle.getKey()
            name: value.name
            description: value.description
            icon: value.icon
            subgraph: value.subgraph
            image: value.image
          }
        )
        if req.accepts("application/hal+json")
          representation["_embedded"] = {
            "joukou:circle": _.map(representation.result, (circle) ->
              circle = _.cloneDeep(circle)
              circle._links =
                self:
                  href: "/circle/#{circle.key}"
              return circle
            )
          }


        res.send(200, representation)
      )
    )
    .fail( ->
      res.send(200, {result:
        []})
    )



