const mongoose = require("mongoose");

const Alert = new mongoose.Schema(
  {
    event: {
      type: String,
    },
    confidence: {
      type: Number,
    },
    timestamp: {
      type: Date,
      default: Date.now,
    },
    image: {
      type: String,
    },
  },
  {
    timestamps: true,
  },
);
module.exports = mongoose.model("alert", Alert);
