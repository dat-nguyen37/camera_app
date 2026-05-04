const User = require("../models/user");
const NotificationHistory = require("../models/notification_history");
const { sendPushNotification } = require("../service/sendNotification");

// POST /api/notification/detect
const sendDetection = async (req, res) => {
  try {
    const { email, cameraId, x, y, w, h, title, body } = req.body;

    if (!email || !cameraId) {
      return res.status(400).json({ error: "Email and cameraId are required" });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    if (!user.deviceTokens || user.deviceTokens.length === 0) {
      return res
        .status(400)
        .json({ error: "User has no device tokens registered" });
    }

    // Prepare coordinate data
    const data = {
      type: "detection",
      cameraId: cameraId,
      x: x ? x.toString() : "0",
      y: y ? y.toString() : "0",
      w: w ? w.toString() : "0",
      h: h ? h.toString() : "0",
    };

    const notifTitle = title || "Cảnh báo Camera";
    const notifBody = body || "Phát hiện có người!";

    // Send to all tokens of this user
    const sendPromises = user.deviceTokens.map((token) =>
      sendPushNotification(token, notifTitle, notifBody, data),
    );

    const results = await Promise.allSettled(sendPromises);

    // Check if at least one succeeded
    const successCount = results.filter((r) => r.status === "fulfilled").length;
    const failures = results.filter((r) => r.status === "rejected");

    // Save to notification history (unread by default)
    if (successCount > 0) {
      await NotificationHistory.create({
        email,
        title: notifTitle,
        body: notifBody,
        cameraId,
        isRead: false,
      });
    }

    res.status(200).json({
      success: `Sent to ${successCount}/${user.deviceTokens.length} devices`,
      results: results.map((r) => r.status),
      failures:
        failures.length > 0 ? failures.map((f) => f.reason.message) : undefined,
    });
  } catch (error) {
    console.error("Error sending detection:", error);
    res.status(500).json({ error: error.message });
  }
};

// GET /api/notification/history?email=...
const getHistory = async (req, res) => {
  try {
    const { email } = req.query;
    if (!email) {
      return res.status(400).json({ error: "Email is required" });
    }

    const history = await NotificationHistory.find({ email })
      .sort({ createdAt: -1 })
      .limit(100);

    const unreadCount = await NotificationHistory.countDocuments({
      email,
      isRead: false,
    });

    res.status(200).json({
      status: "success",
      data: history,
      unreadCount,
    });
  } catch (error) {
    console.error("Error getting history:", error);
    res.status(500).json({ error: error.message });
  }
};

// PUT /api/notification/mark-read
const markAllRead = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ error: "Email is required" });
    }

    await NotificationHistory.updateMany(
      { email, isRead: false },
      { $set: { isRead: true } },
    );

    res
      .status(200)
      .json({ status: "success", message: "Đã đánh dấu tất cả là đã đọc" });
  } catch (error) {
    console.error("Error marking read:", error);
    res.status(500).json({ error: error.message });
  }
};

// GET /api/notification/camera?email=...&cameraId=...&date=...
const getCameraNotifications = async (req, res) => {
  try {
    const { email, cameraId, date } = req.query;
    if (!cameraId) {
      return res.status(400).json({ error: "cameraId are required" });
    }

    let query = { cameraId };
    if (date) {
      const startOfDay = new Date(`${date}T00:00:00+07:00`);
      const endOfDay = new Date(`${date}T23:59:59+07:00`);
      query.createdAt = { $gte: startOfDay, $lte: endOfDay };
    }

    const notifications = await NotificationHistory.find(query).sort({
      createdAt: -1,
    });

    res.status(200).json({
      status: "success",
      data: notifications,
    });
  } catch (error) {
    console.error("Error getting camera notifications:", error);
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  sendDetection,
  getHistory,
  markAllRead,
  getCameraNotifications,
};
