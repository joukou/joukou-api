
/**
@class joukou-api/riak/Meta
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
module.exports = (function() {
  var self;

  self = _Class;

  _Class.keywords = ['bucket', 'contentType', 'key', 'lastMod', 'lastModUsecs', 'type', 'value', 'vclock', 'vtag'];


  /**
  Construct a *MetaValue* from a server reply.
  @static
  @return {joukou-api/riak/MetaValue}
   */

  _Class.fromReply = function(_arg) {
    var bucket, content, key, reply, type;
    type = _arg.type, bucket = _arg.bucket, key = _arg.key, reply = _arg.reply;
    if (reply.content.length !== 1) {
      throw new Error('Unhandled state exception');
    }
    content = reply.content[0];
    return new self({
      type: type,
      bucket: bucket,
      key: key,
      contentType: content.content_type,
      lastMod: content.last_mod,
      lastModUsecs: content.last_mod_usecs,
      value: content.value,
      vclock: reply.vclock,
      vtag: content.vtag
    });
  };


  /**
  @constructor
   */

  function _Class(options) {
    if (options == null) {
      options = {};
    }
    Object.keys(options).forEach((function(_this) {
      return function(key) {
        if (~self.keywords.indexOf(key)) {
          return _this[key] = options[key];
        }
      };
    })(this));
    this.contentType = this._detectContentType();
    return;
  }

  _Class.prototype.getValue = function() {
    return this.value;
  };


  /**
  Get the *Model* associated with `this` *MetaValue*.
  @return {joukou-api/riak/Model}
   */

  _Class.prototype.getModel = function() {
    return this.model;
  };


  /**
  Set the *Model* associated with `this` *MetaValue*.
  @param {joukou-api/riak/Model} model
   */

  _Class.prototype.setModel = function(model) {
    this.model = model;
  };


  /**
  Get the params object suitable for sending to the sever via the protocol
  buffers API.
  @return {!Object}
   */

  _Class.prototype.getParams = function() {
    var content, params;
    params = {};
    if (this.type) {
      params.type = this.type;
    }
    params.bucket = this.bucket;
    params.key = this.key;
    if (this.vclock) {
      params.vclock = this.vclock;
    }
    content = {};
    content.value = this.getSerializedValue();
    content.content_type = this.getContentType();
    if (this.vtag) {
      content.vtag = this.vtag;
    }
    params.content = content;
    return params;
  };


  /**
  Get a serialized representation of the value.
  @return {string}
   */

  _Class.prototype.getSerializedValue = function() {
    switch (this.getContentType()) {
      case 'application/json':
        return JSON.stringify(this.value);
      default:
        return new Buffer(this.value).toString();
    }
  };


  /**
  Automatically detect the content type based on reflection of the value.
  @private
  @return {string}
   */

  _Class.prototype._detectContentType = function() {
    if (this.contentType) {
      return this._expandContentType(this.contentType);
    } else {
      if (this.value instanceof Buffer) {
        return this._expandContentType('binary');
      } else if (typeof this.value === 'object') {
        return this._expandContentType('json');
      } else {
        return this._expandContentType('plain');
      }
    }
  };


  /**
  Expand a shortened content type to the full equivalent.
  @private
  @param {string} type
  @return {string}
   */

  _Class.prototype._expandContentType = function(type) {
    switch (type) {
      case 'json':
        return 'application/json';
      case 'xml':
      case 'html':
      case 'plain':
        return 'text/' + type;
      case 'jpeg':
      case 'gif':
      case 'png':
        return 'image/' + type;
      case 'binary':
        return 'application/octet-stream';
      default:
        return type;
    }
  };

  _Class.prototype.getContentType = function() {
    return this.contentType;
  };

  return _Class;

})();

/*
//# sourceMappingURL=MetaValue.js.map
*/
