const express = require('express')
const { connect } = require('./config/db')
const cors = require('cors')
require('dotenv').config()

const app = express()
app.use(express.json())
app.use(cors())

const userRoute = require('./route/user')
const deviceRoute = require('./route/device')
const notificationRoute = require('./route/notification')
const alertRoute = require('./route/alert')

app.use('/api/user', userRoute)
app.use('/api/device', deviceRoute)
app.use('/api/notification', notificationRoute)
app.use('/api/alert', alertRoute)





connect()
const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on port ${PORT}`)
})