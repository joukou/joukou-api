
/**
@module joukou-api/regexp
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
module.exports = {
  getMatches: function(string, regex, index) {
    var match, matches;
    if (index == null) {
      index = 1;
    }
    matches = [];
    while (match = regex.exec(string)) {
      matches.push(match[index]);
    }
    return matches;
  }
};

/*
//# sourceMappingURL=regexp.js.map
*/
