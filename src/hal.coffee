"use strict"

###*
Copyright 2014 Joukou Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

###*
@module joukou-api/hal
@requires lodash
@requires assert-plus
@author Isaac Johnston <isaac.johnston@joukou.com>

application/hal+json middleware for restify.
###
_           = require('lodash')
assert      = require('assert-plus')
regexp      = require( './regexp' )
{ ForbiddenError } = require( 'restify' )
schemajs    = require( 'schemajs' )

module.exports =
  ###*
  application/hal+json formatter
  @static
  @func formatter
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Object} body
  @return {Object}
  ###
  formatter: ( req, res, body ) ->
    # Binary data
    if Buffer.isBuffer( body )
      data = body.toString( 'base64' )
      res.setHeader( 'Content-Length', Buffer.byteLength( data ) )
      return data

    # Error
    if body instanceof Error
      res.setHeader('Content-Type', 'application/vnd.error+json')
      res.statusCode = body.statusCode or 500
      body =
        logref: body.restCode
        message: body.message
      #  _links: res._links DANGER!

    # HAL+JSON
    # TODO, make this optional
    else if req.accepts('application/hal+json')
      res.setHeader('Content-Type', 'application/hal+json')
      res.link(req.path(), 'self')
      res.link( 'https://rels.joukou.com/{rel}', 'curies', { name: 'joukou', templated: true } )
      body._links = res._links

    data = JSON.stringify(body)
    res.setHeader('Content-Length', Buffer.byteLength(data))

    data

  ###*
  application/hal+json link middleware
  @static
  @func link
  @return {Function}
  ###
  link: ->
    (req, res, next) ->
      if not (
        req.accepts("application/hal+json") or
        req.accepts("application/json")
      )
        # Not Acceptable
        res.send(406)
        return
      ###
      if req.method in [
        "POST"
        "PUT"
      ] and not (
        req.is("application/hal+json") or
        req.is("application/json") or
        req.is("hal+json") or
        req.is("json")
      )
        # Unsupported Media Type
        res.send(415)
        return
      ###
      ###
      @class http.ServerResponse
      @method link
      @param {http.ClientRequest} req
      @param {http.ServerResponse} res
      @param {Function} next
      ###
      res.link = ( href, rel, props = {} ) ->
        assert.string( href )
        assert.string( rel )

        @_links ?= {}
        if rel isnt 'self'
          ( @_links[ rel ] ?= [] ).push( _.extend( props,
            href: href
          ) )
        else
          @_links[ rel ] = _.extend( props, href: href )



      next()

  parse: ( hal, schema ) ->
    result =
      links: {}
      embedded: {}

    if hal._links
      # Validate that _links is defined and an object
      unless _.isObject( hal._links )
        throw new ForbiddenError( '_links must be an object' )

      for rel, links of hal._links
        # Validate that the relation type is supported for this resource
        unless rel is 'curies' or schema.links?.hasOwnProperty( rel )
          throw new ForbiddenError( "the link relation type #{rel} is not supported for this resource" )
        
        # Normalize a Link Object to an array of Link Objects
        if _.isObject( links ) and not _.isArray( links )
          links = [ links ]
        
        # Validate that link values must be a Link Object or an array of Link Objects
        unless _.isArray( links )
          throw new ForbiddenError( 'link values must be a Link Object or an array of Link Objects' )
        
        definition = schema.links[ rel ]
        
        # Validate that the number of links conforms to any schema restrictions
        if _.isNumber( definition.max ) and links.length > definition.max
          throw new ForbiddenError( "the link relation type #{rel} does not support more than #{definition.max} Link Objects for this resource" )

        if _.isNumber( definition.min ) and links.length < definition.min
          throw new ForbiddenError( "the link relation type #{rel} does not support less than #{definition.min} Link Objects for this resource" )

        for link in links
          # Validate that Link Objects have a href property
          unless _.isString( link.href )
            throw new ForbiddenError( 'Link Objects must have a href property' )

          # Extracts keys from href property
          if definition.match
            keys = regexp.getMatches( definition.match, /\/:([a-zA-Z]+)\/?/g )
            values = regexp.getMatches( link.href, /(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})/g )
            unless keys.length is values.length
              throw new ForbiddenError( 'failed to extract keys from href property' )
            obj = _.zipObject( keys, values )
          else
            obj = {}

          if definition.name
            unless _.isString( link.name )
              if definition.name.required
                throw new ForbiddenError( "the link relation type #{rel} requires a name property" )
            else
              if definition.name.type is 'enum'
                unless link.name in definition.name.values
                  throw new ForbiddenError( "the link relation type #{rel} requires a name property value that is one of: " + definition.name.values.join(', ') )
              obj.name = link.name

          if _.isPlainObject(definition.properties)
            for key of definition.properties
              if not definition.properties.hasOwnProperty(key)
                continue
              schema = definition.properties[key]
              form = schemajs.test(link[key], schema)
              if not form.valid
                throw new ForbiddenError(form.errors[0])
              obj[key] = link[key]

          (result.links[ rel ] ?= []).push( obj )

      # Double-check for non-existent values that have a minimum number of links
      for rel, definition of schema.links
        if definition.min and not result.links[rel]?.length >= definition.min
          throw new ForbiddenError( "the link relation type #{rel} does not support less than #{definition.min} Link Objects for this resource" )

    result



