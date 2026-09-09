import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
//import fetch from "node-fetch";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

//const GROQ_API_KEY = "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";

export const sendDisruptionAlerts = functions.pubsub
  .schedule("0 * * * *")
  .timeZone("Africa/Kampala")
  .onRun(async () => {
    try {
      const marketDoc = await db.collection("market_data").doc("latest").get();

      if (!marketDoc.exists) return null;

      const traffic = marketDoc.data()?.traffic || [];

      for (const item of traffic) {
        if (item.condition === "Heavy") {

        const usersSnapshot = await db.collection("users")
          .where("roles", "array-contains-any", ["passenger", "driver", "conductor"])
          .limit(100)
          .get();
          //const usersSnapshot = await db.collection("users")
            //.where("role", "==", "passenger")
            //.limit(100)
            //.get();

          const batch = db.batch();

          usersSnapshot.docs.forEach((doc) => {
            const notificationRef = db.collection("notifications").doc();

            batch.set(notificationRef, {
              user_id: doc.id,
              title: "Heavy Traffic Alert",
              body: `${item.road} is experiencing heavy traffic. Plan your trip accordingly.`,
              type: "traffic_alert",
              read: false,
              created_at: admin.firestore.FieldValue.serverTimestamp(),
            });
          });

          await batch.commit();
        }
      }

      return null;
    } catch (e) {
      console.error("Alert failed:", e);
      return null;
    }
  });