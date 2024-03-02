const mongoose    = require('mongoose')
const MONGO_URI = 'mongodb://localhost/devops'
const MONGO_OPTIONS = { connectTimeoutMS: 40000 }

const conn = mongoose.createConnection(MONGO_URI, MONGO_OPTIONS)

const message = new mongoose.Schema({
  msg:        { type: String },
  msgId:      { type: String },
  attributes: { type: Object }
})

conn.on('connected',    () => { console.log('Mongoose connection open to meta db') })
conn.on('error',        err => { console.log(`Mongoose connection error to meta db: ${err}`) })
conn.on('disconnected', () => { console.log('Mongoose connection disconnected meta db') })


module.exports = {
  Message: conn.model('Message', message)
}