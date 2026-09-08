import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import fetch from "node-fetch";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

const FLUTTERWAVE_SECRET_KEY = "YOUR_SECRET_KEY";

export const createPayment = functions.https.onCall(async (data, context) => {
  const { amount, phone, email, bookingId, paymentType } = data;

  if (!amount || !phone) {
    throw new functions.https.HttpsError("invalid-argument", "Amount and phone required");
  }

  try {
    const response = await fetch("https://api.flutterwave.com/v3/charges?type=mobile_money_uganda", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${FLUTTERWAVE_SECRET_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        amount: amount,
        currency: "UGX",
        phone_number: phone,
        email: email || "customer@smartstage.com",
        tx_ref: `smartstage_${Date.now()}`,
        redirect_url: "https://smartstage.com/payment-success",
      }),
    });

    const result = await response.json() as any;

    if (result.status === "success") {
      await db.collection("payments").add({
        booking_id: bookingId || "",
        amount: amount,
        phone: phone,
        status: "PENDING",
        tx_ref: result.data.tx_ref,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, tx_ref: result.data.tx_ref };
    }

    return { success: false, message: result.message || "Payment failed" };
  } catch (e) {
    return { success: false, message: e };
  }
});

//the webhook function
export const flutterwaveWebhook = functions.https.onRequest(async (req, res) => {
  const payload = req.body;

  if (payload.status === "successful") {
    const txRef = payload.tx_ref;

    const paymentsSnapshot = await db.collection("payments")
      .where("tx_ref", "==", txRef)
      .limit(1)
      .get();

    if (!paymentsSnapshot.empty) {
      const paymentDoc = paymentsSnapshot.docs[0];
      await paymentDoc.ref.update({
        status: "COMPLETED",
        completed_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }

  res.status(200).send("OK");
});