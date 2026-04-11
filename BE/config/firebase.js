// firebase.js
const admin = require("firebase-admin");
const path = require("path");
require("dotenv").config();
const serviceAccountPath = path.resolve("./account_service.json");

admin.initializeApp({
  credential: admin.credential.cert(require(serviceAccountPath)),
});

module.exports = admin;
