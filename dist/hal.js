"use strict";

/**
@module joukou-api/hal
@requires lodash
@requires assert-plus
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
@author Isaac Johnston <isaac.johnston@joukou.com>

application/hal+json middleware for restify.
 */
var ForbiddenError, assert, regexp, schemajs, _,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

_ = require('lodash');

assert = require('assert-plus');

regexp = require('./regexp');

ForbiddenError = require('restify').ForbiddenError;

schemajs = require('schemajs');

module.exports = {

  /**
  application/hal+json formatter
  @static
  @func formatter
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Object} body
  @return {Object}
   */
  formatter: function(req, res, body) {
    var data;
    if (Buffer.isBuffer(body)) {
      data = body.toString('base64');
      res.setHeader('Content-Length', Buffer.byteLength(data));
      return data;
    }
    if (body instanceof Error) {
      res.setHeader('Content-Type', 'application/vnd.error+json');
      res.statusCode = body.statusCode || 500;
      body = {
        logref: body.restCode,
        message: body.message
      };
    } else if (req.accepts('application/hal+json')) {
      res.setHeader('Content-Type', 'application/hal+json');
      res.link(req.path(), 'self');
      res.link('https://rels.joukou.com/{rel}', 'curies', {
        name: 'joukou',
        templated: true
      });
      body._links = res._links;
    }
    data = JSON.stringify(body);
    res.setHeader('Content-Length', Buffer.byteLength(data));
    return data;
  },

  /**
  application/hal+json link middleware
  @static
  @func link
  @return {Function}
   */
  link: function() {
    return function(req, res, next) {
      if (!(req.accepts("application/hal+json") || req.accepts("application/json"))) {
        res.send(406);
        return;
      }

      /*
      if req.method in [
        "POST"
        "PUT"
      ] and not (
        req.is("application/hal+json") or
        req.is("application/json") or
        req.is("hal+json") or
        req.is("json")
      )
         * Unsupported Media Type
        res.send(415)
        return
       */

      /*
      @class http.ServerResponse
      @method link
      @param {http.ClientRequest} req
      @param {http.ServerResponse} res
      @param {Function} next
       */
      res.link = function(href, rel, props) {
        var _base;
        if (props == null) {
          props = {};
        }
        assert.string(href);
        assert.string(rel);
        if (this._links == null) {
          this._links = {};
        }
        if (rel !== 'self') {
          return ((_base = this._links)[rel] != null ? _base[rel] : _base[rel] = []).push(_.extend(props, {
            href: href
          }));
        } else {
          return this._links[rel] = _.extend(props, {
            href: href
          });
        }
      };
      return next();
    };
  },
  parse: function(hal, schema) {
    var definition, form, key, keys, link, links, obj, rel, result, values, _base, _i, _len, _ref, _ref1, _ref2, _ref3, _ref4;
    result = {
      links: {},
      embedded: {}
    };
    if (hal._links) {
      if (!_.isObject(hal._links)) {
        throw new ForbiddenError('_links must be an object');
      }
      _ref = hal._links;
      for (rel in _ref) {
        links = _ref[rel];
        if (!(rel === 'curies' || ((_ref1 = schema.links) != null ? _ref1.hasOwnProperty(rel) : void 0))) {
          throw new ForbiddenError("the link relation type " + rel + " is not supported for this resource");
        }
        if (_.isObject(links) && !_.isArray(links)) {
          links = [links];
        }
        if (!_.isArray(links)) {
          throw new ForbiddenError('link values must be a Link Object or an array of Link Objects');
        }
        definition = schema.links[rel];
        if (_.isNumber(definition.max) && links.length > definition.max) {
          throw new ForbiddenError("the link relation type " + rel + " does not support more than " + definition.max + " Link Objects for this resource");
        }
        if (_.isNumber(definition.min) && links.length < definition.min) {
          throw new ForbiddenError("the link relation type " + rel + " does not support less than " + definition.min + " Link Objects for this resource");
        }
        for (_i = 0, _len = links.length; _i < _len; _i++) {
          link = links[_i];
          if (!_.isString(link.href)) {
            throw new ForbiddenError('Link Objects must have a href property');
          }
          if (definition.match) {
            keys = regexp.getMatches(definition.match, /\/:([a-zA-Z]+)\/?/g);
            values = regexp.getMatches(link.href, /(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})/g);
            if (keys.length !== values.length) {
              throw new ForbiddenError('failed to extract keys from href property');
            }
            obj = _.zipObject(keys, values);
          } else {
            obj = {};
          }
          if (definition.name) {
            if (!_.isString(link.name)) {
              if (definition.name.required) {
                throw new ForbiddenError("the link relation type " + rel + " requires a name property");
              }
            } else {
              if (definition.name.type === 'enum') {
                if (_ref2 = link.name, __indexOf.call(definition.name.values, _ref2) < 0) {
                  throw new ForbiddenError(("the link relation type " + rel + " requires a name property value that is one of: ") + definition.name.values.join(', '));
                }
              }
              obj.name = link.name;
            }
          }
          if (_.isPlainObject(definition.properties)) {
            for (key in definition.properties) {
              if (!definition.properties.hasOwnProperty(key)) {
                continue;
              }
              schema = definition.properties[key];
              form = schemajs.test(link[key], schema);
              if (!form.valid) {
                throw new ForbiddenError(form.errors[0]);
              }
              obj[key] = link[key];
            }
          }
          ((_base = result.links)[rel] != null ? _base[rel] : _base[rel] = []).push(obj);
        }
      }
      _ref3 = schema.links;
      for (rel in _ref3) {
        definition = _ref3[rel];
        if (definition.min && !((_ref4 = result.links[rel]) != null ? _ref4.length : void 0) >= definition.min) {
          throw new ForbiddenError("the link relation type " + rel + " does not support less than " + definition.min + " Link Objects for this resource");
        }
      }
    }
    return result;
  }
};

/*
//# sourceMappingURL=hal.js.map
*/
