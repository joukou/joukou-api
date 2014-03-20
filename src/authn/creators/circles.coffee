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

