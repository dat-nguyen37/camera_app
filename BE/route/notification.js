const express = require("express");
const router = express.Router();
const { sendDetection, getHistory, markAllRead, getCameraNotifications } = require("../controller/notification");

router.post("/detect", sendDetection);
router.get("/history", getHistory);
router.get("/camera", getCameraNotifications);
router.put("/mark-read", markAllRead);

module.exports = router;
