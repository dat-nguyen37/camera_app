const express = require("express");
const router = express.Router();
const alertController = require("../controller/alert");

router.get("/", alertController.getAlerts);

module.exports = router;
