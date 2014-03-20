"use strict"

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

###*
Simple contact service for sending an email to Joukou.

@module joukou-api/routes/contact
@requires joukou-api/config
@requires nodemailer
@author Isaac Johnston <isaac.johnston@joukou.com>
###

###
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
###

config = require( '../config' )
mailer = require( 'nodemailer' )
log  = require( '../log/LoggerFactory' ).getLogger( name: 'server' )


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
    smtp = mailer.createTransport(
      config.mailer.transport, config.mailer.transport_options )
    
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
      from: config.mailer.sender
      to: config.mailer.recipients
      subject: subject
      text: text

    smtp.sendMail( message, ( err, smtpRes ) ->
      if err
        log.fatal(
          "Unable to send message via #{config.mailer.transport}: " + err
        )
        res.send( 503 )
      else
        res.send( 201 )

      return
    )

    return
