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

BearerStrategy  = require( 'passport-http-bearer' ).Strategy
token           = require( '../token' )


module.exports =
  authenticate: null
  generate: token.generate
  Strategy: null
  setup: ( passport ) ->
    passport.use(this.Strategy = new BearerStrategy(token.verify))
    this.authenticate = passport.authenticate(
      'bearer',
      session: false
    )