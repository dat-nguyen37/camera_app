const express = require('express')
const { connect } = require('./config/db')
const cors = require('cors')

const app = express()
app.use(express.json())
app.use(cors())

const userRoute = require('./route/user')
const deviceRoute = require('./route/device')







app.use('/api/user', userRoute)
app.use('/api/device', deviceRoute)






app.listen(5000, "192.168.1.6", () => {
    console.log('Server runing on port 5000')
    connect()
})