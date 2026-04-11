const express = require("express");
const router = express.Router();
const { sendDetection } = require("../controller/notification");

router.post("/detect", sendDetection);

module.exports = router;
