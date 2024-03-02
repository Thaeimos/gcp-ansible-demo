'use strict';
const db = require('./db')

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
      console.log(`Received message ${message.id}:`);
      console.log(`\tData: ${message.data}`);
      console.log(`\tAttributes: ${message.attributes}`);
      messageCount += 1;

      // save message
      db.Message.create({msg: data.msg, msgId: message.id, attributes: message.attributes}, err => {
        if (err) {
          console.error(err)
          return
        }

        // "Ack" (acknowledge receipt of) the message
        message.ack();
      })
    };

    // Listen for new messages until timeout is hit
    subscription.on('message', messageHandler);

    setInterval(() => {
      console.log(`${messageCount} message(s) received.`)
      messageCount = 0
    }, timeout * 1000)
  }

  listenForMessages();
}

main(...process.argv.slice(2));