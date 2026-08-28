import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();

// ============================================================
// TYPE DEFINITIONS
// ============================================================
interface CreateEscrowInput {
  booking_id: string;
  passenger_id: string;
  driver_id: string;
  amount: number;
}

interface ReleaseEscrowInput {
  escrow_id: string;
}

interface RefundEscrowInput {
  escrow_id: string;
}

// ============================================================
// CREATE ESCROW
// ============================================================
export const createEscrow = functions.https.onCall(async (data, context) => {
  const { booking_id, passenger_id, driver_id, amount } = (data || {}) as Partial<CreateEscrowInput>;

  if (!booking_id || !passenger_id || !driver_id || typeof amount !== "number") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "booking_id, passenger_id, driver_id, and valid amount required"
    );
  }

  if (amount <= 0) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Amount must be greater than zero"
    );
  }

  // Verify booking exists
  const bookingRef = db.collection("bookings").doc(booking_id);
  const bookingDoc = await bookingRef.get();

  if (!bookingDoc.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      "Booking not found"
    );
  }

  const bookingData = bookingDoc.data();

  // Check booking is in correct state
  if (bookingData?.status !== "matched") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Booking must be matched before escrow"
    );
  }

  // Check if escrow already exists
  const existingEscrow = await db.collection("escrow_transactions")
    .where("booking_id", "==", booking_id)
    .where("status", "==", "HELD")
    .get();

  if (!existingEscrow.empty) {
    throw new functions.https.HttpsError(
      "already-exists",
      "Escrow already exists for this booking"
    );
  }

  // Create escrow
  const escrowRef = db.collection("escrow_transactions").doc();
  const escrowData = {
    booking_id,
    passenger_id,
    driver_id,
    amount,
    status: "HELD",
    created_at: admin.firestore.FieldValue.serverTimestamp(),
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
    release_attempts: 0,
  };

  await escrowRef.set(escrowData);

  // Update booking payment status
  await bookingRef.update({
    payment_status: "IN_ESCROW",
    escrow_id: escrowRef.id,
  });

  // Notify driver
  await db.collection("notifications").add({
    user_id: driver_id,
    title: "Payment in Escrow",
    body: `UGX ${amount} has been held in escrow for booking ${booking_id}`,
    type: "ESCROW_CREATED",
    booking_id,
    read: false,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {
    success: true,
    escrow_id: escrowRef.id,
    status: "HELD",
  };
});

// ============================================================
// RELEASE ESCROW
// ============================================================
export const releaseEscrow = functions.https.onCall(async (data, context) => {
  const { escrow_id } = (data || {}) as Partial<ReleaseEscrowInput>;

  if (!escrow_id) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "escrow_id required"
    );
  }

  const escrowRef = db.collection("escrow_transactions").doc(escrow_id);
  const escrowDoc = await escrowRef.get();

  if (!escrowDoc.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      "Escrow not found"
    );
  }

  const escrowData = escrowDoc.data();

  if (escrowData?.status !== "HELD") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Escrow is not in HELD state"
    );
  }

  // Verify caller is passenger
  if (context.auth?.uid !== escrowData?.passenger_id) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only passenger can release escrow"
    );
  }

  // Mark as released
  await escrowRef.update({
    status: "RELEASED",
    released_at: admin.firestore.FieldValue.serverTimestamp(),
    released_by: context.auth?.uid,
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Update booking
  if (escrowData?.booking_id) {
    await db.collection("bookings").doc(escrowData.booking_id).update({
      payment_status: "PAID",
    });
  }

  // Notify driver
  if (escrowData?.driver_id) {
    await db.collection("notifications").add({
      user_id: escrowData.driver_id,
      title: "Payment Released",
      body: `UGX ${escrowData.amount} has been released to you`,
      type: "ESCROW_RELEASED",
      booking_id: escrowData.booking_id,
      read: false,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  return {
    success: true,
    status: "RELEASED",
  };
});

// ============================================================
// REFUND ESCROW
// ============================================================
export const refundEscrow = functions.https.onCall(async (data, context) => {
  const { escrow_id } = (data || {}) as Partial<RefundEscrowInput>;

  if (!escrow_id) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "escrow_id required"
    );
  }

  const escrowRef = db.collection("escrow_transactions").doc(escrow_id);
  const escrowDoc = await escrowRef.get();

  if (!escrowDoc.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      "Escrow not found"
    );
  }

  const escrowData = escrowDoc.data();

  if (escrowData?.status !== "HELD") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Escrow is not in HELD state"
    );
  }

  // Verify caller is passenger or driver
  if (context.auth?.uid !== escrowData?.passenger_id &&
      context.auth?.uid !== escrowData?.driver_id) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Not authorized to refund"
    );
  }

  // Mark as refunded
  await escrowRef.update({
    status: "REFUNDED",
    refunded_at: admin.firestore.FieldValue.serverTimestamp(),
    refunded_by: context.auth?.uid,
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Update booking
  if (escrowData?.booking_id) {
    await db.collection("bookings").doc(escrowData.booking_id).update({
      payment_status: "REFUNDED",
      status: "cancelled",
    });
  }

  // Notify both parties
  if (escrowData?.driver_id) {
    await db.collection("notifications").add({
      user_id: escrowData.driver_id,
      title: "Escrow Refunded",
      body: `Payment of UGX ${escrowData.amount} has been refunded`,
      type: "ESCROW_REFUNDED",
      booking_id: escrowData.booking_id,
      read: false,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  if (escrowData?.passenger_id) {
    await db.collection("notifications").add({
      user_id: escrowData.passenger_id,
      title: "Escrow Refunded",
      body: `Your payment of UGX ${escrowData.amount} has been refunded`,
      type: "ESCROW_REFUNDED",
      booking_id: escrowData.booking_id,
      read: false,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  return {
    success: true,
    status: "REFUNDED",
  };
});