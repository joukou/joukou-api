###*
@module joukou-api/regexp
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###
module.exports =
  getMatches: ( string, regex, index = 1 ) ->
    matches = []
    while match = regex.exec( string )
      matches.push( match[ index ] )
    matches