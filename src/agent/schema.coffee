"use strict"

###*
@module joukou-api/agent/schema
@requires schemajs
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

schema = require( 'schemajs' )
###
agent.email = profile.email
agent.githubLogin = profile.login
agent.githubId = profile.id
agent.imageUrl = profile.avatar_url
agent.website = profile.blog
agent.githubUrl = profile.url
agent.name = profile.name
agent.company = profile.company
agent.location = profile.location
###
module.exports = schema.create(
  email:
    type: 'email'
    required: true
    allownull: false
    filters: [ 'trim' ]
  github_login:
    type: 'string'
    required: false
    allownull: true
  github_id:
    type: 'integer'
    required: false
    allownull: true
  image_url:
    type: 'string'
    required: false
    allownull: false
  website:
    type: 'url'
    required: false
    allownull: false
  github_url:
    type: 'url'
    required: false
    allownull: false
  name:
    type: 'string'
    required: false
    allownull: false
  company:
    type: 'string'
    required: false
    allownull: false
  location:
    type: 'string'
    required: false
    allownull: false
)