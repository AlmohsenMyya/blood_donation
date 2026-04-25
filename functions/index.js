const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Returns a list of blood types that can DONATE to the given recipient type.
 */
function getCompatibleDonors(recipientType) {
  const allTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
  switch (recipientType) {
    case "AB+": return allTypes;
    case "AB-": return ["AB-", "A-", "B-", "O-"];
    case "A+": return ["A+", "A-", "O+", "O-"];
    case "A-": return ["A-", "O-"];
    case "B+": return ["B+", "B-", "O+", "O-"];
    case "B-": return ["B-", "O-"];
    case "O+": return ["O+", "O-"];
    case "O-": return ["O-"];
    default: return [recipientType];
  }
}

/**
 * Triggered when a blood request is verified.
 * Sends notifications to compatible donors in the same city.
 */
exports.onVerifyRequest = onDocumentUpdated("blood_requests/{requestId}", async (event) => {
  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();

  // Trigger only when isVerified changes from false to true
  if (beforeData.isVerified === false && afterData.isVerified === true) {
    const city = afterData.city;
    const bloodGroup = afterData.bloodGroup;
    const patientName = afterData.patientName || "A patient";

    console.log(`Request verified for ${patientName} in ${city} (${bloodGroup}).`);

    const compatibleTypes = getCompatibleDonors(bloodGroup);

    // Find donors in the same city with compatible blood types
    const donorsSnapshot = await admin.firestore()
      .collection("users")
      .where("role", "==", "donor")
      .where("city", "==", city)
      .where("bloodGroup", "in", compatibleTypes)
      .get();

    if (donorsSnapshot.empty) {
      console.log("No compatible donors found in this city.");
      return;
    }

    const tokens = [];
    donorsSnapshot.forEach(doc => {
      const data = doc.data();
      if (data.fcmToken) {
        tokens.push(data.fcmToken);
      }
    });

    if (tokens.length === 0) {
      console.log("No FCM tokens found for compatible donors.");
      return;
    }

    // Prepare notification message
    const message = {
      notification: {
        title: "🆘 Urgent Blood Request!",
        body: `A verified case for ${bloodGroup} in ${city} needs your help. Donate now!`,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        requestId: event.params.requestId,
        type: "emergency",
      },
      tokens: tokens,
    };

    // Send notifications
    try {
      const response = await admin.messaging().sendEachForMulticast(message);
      console.log(`${response.successCount} notifications sent successfully.`);
    } catch (error) {
      console.error("Error sending notifications:", error);
    }
  }
});
