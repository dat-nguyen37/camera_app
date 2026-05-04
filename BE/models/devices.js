const mongoose = require('mongoose')

const Device = new mongoose.Schema({
    device_name: {
        type: String
    },
    url: {
        type: String,
    },
    detection_roi: {
        x: { type: Number, default: 0 },
        y: { type: Number, default: 0 },
        width: { type: Number, default: 100 },
        height: { type: Number, default: 100 }
    },
    is_detection_enabled: {
        type: Boolean,
        default: false
    }
},
    {
        timestamps: true
    })
module.exports = mongoose.model('device', Device)