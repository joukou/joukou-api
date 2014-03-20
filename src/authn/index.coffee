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

passport  = require( 'passport' )

Github    = require( './github' )
Bearer    = require( './bearer' )

Github.setup( passport )
Bearer.setup( passport )

module.exports =
  Github: Github
  Bearer: Bearer
  # Default authentication method
  # Usage:
  #   In the request body or query string
  #     access_token=#{Bearer.generate(agent, false)}
  #   In the headers:
  #     Authorization: Bearer #{Bearer.generate(agent)}
  authenticate: Bearer.authenticate
  middleware: ->
    return passport.initialize()