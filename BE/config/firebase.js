// firebase.js
const admin = require("firebase-admin");
const path = require("path");
require("dotenv").config();
const serviceAccount = JSON.parse(process.env.GCP_SERVICE_ACCOUNT);
serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, "\n");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;
