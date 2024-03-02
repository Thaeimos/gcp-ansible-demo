'use strict';
const db = require('./db')

const winston = require('winston');

const logger = winston.createLogger({
  level: 'verbose',
  format: winston.format.json(),
  defaultMeta: { service: 'user-service' },
  transports: [
    //
    // - Write all logs with importance level of `error` or less to `error.log`
    // - Write all logs with importance level of `info` or less to `combined.log`
    //
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'application.log' }),
  ],
});

//
// If we're not in production then log to the `console` with the format:
// `${info.level}: ${info.message} JSON.stringify({ ...rest }) `
//

function main(
  subscriptionNameOrId = 'api_events',
  timeout = 60
) {
  timeout = Number(timeout);

  // Imports the Google Cloud client library
  const {PubSub} = require('@google-cloud/pubsub');

  // Creates a client; cache this for further use
  const pubSubClient = new PubSub();

  function listenForMessages() {
    // References an existing subscription
    const subscription = pubSubClient.subscription(subscriptionNameOrId);

    // Create an event handler to handle messages
    let messageCount = 0;
    const messageHandler = message => {
      const data = JSON.parse(message.data.toString())
      logger.info(`Received message ${message.id}:`);
      logger.info(`\tData: ${message.data}`);
      logger.info(`\tAttributes: ${message.attributes}`);
      messageCount += 1;

      // save message
      db.Message.create({msg: data.msg, msgId: message.id, attributes: message.attributes}, err => {
        if (err) {
          logger.error(err)
          return
        }

        // "Ack" (acknowledge receipt of) the message
        message.ack();
      })
    };

    // Listen for new messages until timeout is hit
    subscription.on('message', messageHandler);

    setInterval(() => {
      logger.info(`${messageCount} message(s) received.`)
      messageCount = 0
    }, timeout * 1000)
  }

  listenForMessages();
}

main(...process.argv.slice(2));