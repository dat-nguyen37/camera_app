// sendNotification.js
const admin = require("../config/firebase");

async function sendPushNotification(token, title, body, data) {
    const message = {
        token: token,
        notification: title ? {
            title: title,
            body: body,
        } : undefined,
        data: data || {},
    };

    try {
        const response = await admin.messaging().send(message);
        console.log("✅ Successfully sent:", response);
        return response;
    } catch (error) {
        console.error("❌ Error sending to token:", token, error);
        throw error;
    }
}

module.exports = { sendPushNotification };
