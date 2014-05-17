"use strict"

###*
Simple contact service for sending an email to Joukou.

@module joukou-api/routes/contact
@requires joukou-api/config
@requires nodemailer
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

config = require( '../config' )
mailer = require( 'nodemailer' )

self = module.exports =
  ###*
  Register the `/contact` routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.post( '/contact', self._contact )

  ###*
  Handle a `POST /contact` request.
  @protected
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  ###
  _contact: ( req, res ) ->
    smtp = mailer.createTransport( 'SMTP', config.smtp )
    
    name = if req.body.name?.length then req.body.name else 'Anonymous'

    if req.body.message?.length
      subject = "Joukou message from #{name}"
      text = """
             #{req.body.message}

             Name: #{name}
             Email: #{req.body.email}
             """
    else
      subject = "Joukou signup from #{name}"
      text = """
             #{name} with the email address #{req.body.email} has signed up for
             Joukou!
             """

    message =
      from: config.sender
      to: config.recipients
      subject: subject
      text: text

    smtp.sendMail( message, ( err, smtpRes ) ->
      if err
        res.send( 503 )
      else
        res.send( 201 )

      return
    )

    return
