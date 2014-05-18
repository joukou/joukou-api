"use strict"

###*
Simple contact service for sending an email to Joukou.

@module joukou-api/routes/contact
@requires joukou-api/config
@requires nodemailer
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

###
@api {post} /contact Send a message to Joukou staff
@apiName Contact
@apiGroup Contact

@apiParam {String} name The name of the person sending the message
@apiParam {String} email The email address of the person sending the message
@apiParam {String} message The plaintext content of the message

@apiExample CURL Example:
  curl -i -X POST https://api.joukou.com/contact
    -H 'Content-Type: application/json' \
    -d '{ "name": "Isaac Johnston", "email": "isaac.johnston@joukou.com", "message": "API Example" }'

@apiSuccess (201) Created The message has been sent successfully.

@apiError (429) TooManyRequests The client has sent too many requests in a given amount of time.

@apiError (503) ServiceUnavailable There was a temporary failure sending the message, the client should try again later.
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
