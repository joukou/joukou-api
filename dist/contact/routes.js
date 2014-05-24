"use strict";

/**
Simple contact service for sending an email to Joukou.

@module joukou-api/routes/contact
@requires joukou-api/config
@requires nodemailer
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */

/*
@api {post} /contact Send a message to Joukou staff
@apiName Contact
@apiGroup Contact

@apiParam {String} name The name of the person sending the message
@apiParam {String} email The email address of the person sending the message
@apiParam {String} message The plaintext content of the message

@apiExample CURL Example:
  curl -i -X POST https://api.joukou.com/contact \
    -H 'Content-Type: application/json' \
    -d '{ "name": "Isaac Johnston", "email": "isaac.johnston@joukou.com", "message": "API Example" }'

@apiSuccess (201) Created The message has been sent successfully.

@apiError (429) TooManyRequests The client has sent too many requests in a given amount of time.

@apiError (503) ServiceUnavailable There was a temporary failure sending the message, the client should try again later.
 */
var config, log, mailer, self;

config = require('../config');

mailer = require('nodemailer');

log = require('../log/LoggerFactory').getLogger({
  name: 'server'
});

self = module.exports = {

  /**
  Register the `/contact` routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    return server.post('/contact', self._contact);
  },

  /**
  Handle a `POST /contact` request.
  @protected
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
   */
  _contact: function(req, res) {
    var message, name, smtp, subject, text, _ref, _ref1;
    smtp = mailer.createTransport('SES', config.ses);
    name = ((_ref = req.body.name) != null ? _ref.length : void 0) ? req.body.name : 'Anonymous';
    if ((_ref1 = req.body.message) != null ? _ref1.length : void 0) {
      subject = "Joukou message from " + name;
      text = "" + req.body.message + "\n\nName: " + name + "\nEmail: " + req.body.email;
    } else {
      subject = "Joukou signup from " + name;
      text = "" + name + " with the email address " + req.body.email + " has signed up for\nJoukou!";
    }
    message = {
      from: config.sender,
      to: config.recipients,
      subject: subject,
      text: text
    };
    smtp.sendMail(message, function(err, smtpRes) {
      if (err) {
        log.fatal('Unable to send message via Amazon SES: ' + err);
        res.send(503);
      } else {
        res.send(201);
      }
    });
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
