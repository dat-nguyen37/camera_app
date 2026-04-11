const User = require("../models/user");
const { sendPushNotification } = require("../service/sendNotification");

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
      return res.status(400).json({ error: "User has no device tokens registered" });
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

    // Send to all tokens of this user
    const sendPromises = user.deviceTokens.map((token) =>
      sendPushNotification(
        token,
        title || "Cảnh báo Camera", 
        body || "Phát hiện có người!", 
        data
      )
    );

    const results = await Promise.allSettled(sendPromises);
    
    // Check if at least one succeeded
    const successCount = results.filter(r => r.status === 'fulfilled').length;
    const failures = results.filter(r => r.status === 'rejected');

    res.status(200).json({
      success: `Sent to ${successCount}/${user.deviceTokens.length} devices`,
      results: results.map(r => r.status),
      failures: failures.length > 0 ? failures.map(f => f.reason.message) : undefined
    });
    
  } catch (error) {
    console.error("Error sending detection:", error);
    res.status(500).json({ error: error.message });
  }
};

module.exports = { sendDetection };
