const mongoose = require("mongoose");

const NotificationHistorySchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: true,
      index: true,
    },
    title: {
      type: String,
      default: "Cảnh báo Camera",
    },
    body: {
      type: String,
      default: "",
    },
    cameraId: {
      type: String,
      default: "",
    },
    isRead: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("NotificationHistory", NotificationHistorySchema);
