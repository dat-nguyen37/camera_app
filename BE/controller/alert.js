const Alert = require("../models/alerts");

const getAlerts = async (req, res) => {
  try {
    const alerts = await Alert.find().sort({ timestamp: -1 }).limit(100);

    const formattedAlerts = alerts.map((alert) => {
      let title = "Cảnh báo Camera";
      let body = "Phát hiện sự kiện lạ";

      if (alert.event === "intrusion") {
        title = "CẢNH BÁO XÂM NHẬP";
        body = "phát hiện người lạ";
      } else if (alert.event === "unknown_face") {
        title = "NGƯỜI LẠ";
        body = "phát hiện người lạ chưa đăng kí";
      }

      return {
        _id: alert._id,
        event: alert.event,
        confidence: alert.confidence,
        image: alert.image,
        title,
        body,
        createdAt: alert.timestamp,
      };
    });
    res.status(200).json({
      status: "success",
      data: formattedAlerts,
      unreadCount: 0, // Placeholder as alerts don't have isRead status yet
    });
  } catch (error) {
    console.error("Error getting alerts:", error);
    res.status(500).json({ error: error.message });
  }
};

module.exports = { getAlerts };
