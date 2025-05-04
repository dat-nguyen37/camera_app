const mongoose = require('mongoose')

const Device = new mongoose.Schema({
    device_name: {
        type: String
    },
    url: {
        type: String,
    },
},
    {
        timestamps: true
    })
module.exports = mongoose.model('device', Device)