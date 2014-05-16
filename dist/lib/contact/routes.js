"use strict";

/**
Simple contact service for sending an email to Joukou.

@module joukou-api/routes/contact
@requires joukou-api/config
@requires nodemailer
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var config, mailer, self;

config = require('../config');

mailer = require('nodemailer');

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
    smtp = mailer.createTransport('SMTP', config.smtp);
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
