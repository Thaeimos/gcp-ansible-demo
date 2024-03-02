const express = require('express')
const {PubSub} = require('@google-cloud/pubsub')

const app = express()
const port = 3001
const pubSubClient = new PubSub()
const topicName = 'api_events'

async function publishMessage(data) {
  const dataBuffer = Buffer.from(data)
  const messageId = await pubSubClient.topic(topicName).publish(dataBuffer)
  console.log(`Message ${messageId} published.`)
  return messageId
}

// logger
app.use('/', (req, res, next) => {
  console.log(`[${req.method}] ${req.originalUrl}`);
  return next();
})

// Check app status
app.get('/', (req, res) => {
  res.send('Up and running!!')
})

// Send message to queue
app.get('/msg', (req, res) => {
  const msg = { msg: req.query.msg }
  publishMessage(JSON.stringify(msg)).then(() => {
    res.send('Message sent to pubsub!')
  }).catch(e => {
    res.send(`Failed with ${e.name}: ${e.message}`)
  })
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})