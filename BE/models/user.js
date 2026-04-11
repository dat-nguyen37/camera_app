const mongoose = require("mongoose");

const User = new mongoose.Schema(
  {
    name: {
      type: String,
    },
    email: {
      type: String,
    },
    password: {
      type: String,
    },
    deviceTokens: {
      type: [String],
      default: [],
    },
  },
  {
    timestamps: true,
  },
);
module.exports = mongoose.model("user", User);
