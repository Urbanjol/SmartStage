import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export * from "./escrow_functions";
export * from "./chat_functions";
export * from "./assistant_functions";

if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();

// ============================================================
// TYPE DEFINITIONS
// ============================================================
interface LocationInput {
  lat: number;
  lng: number;
}

interface FindJourneyInput {
  origin: LocationInput;
  destination: string;
  preference?: string;
}

interface UpdateLocationInput {
  matatu_id: string;
  driver_id?: string;
  location: LocationInput;
  speed?: number;
  heading?: number;
  seats_available?: number;
  status?: string;
}

interface UpdateSeatStatusInput {
  matatu_id: string;
  seat_state: string;
}

interface CreateBookingInput {
  passenger_id: string;
  matatu_id: string;
  origin_stage?: string;
  destination_stage?: string;
  seats?: number;
  fare?: number;
  booking_type?: string;
}

interface AddStageInput {
  name: string;
  location: LocationInput;
  added_by?: string;
}

// ============================================================
// FUNCTION 1: FIND JOURNEY
// ============================================================
export const findJourney = functions.https.onCall(async (data, context) => {
  const { origin, destination, preference } = (data || {}) as Partial<FindJourneyInput>;

  if (!origin || typeof origin.lat !== "number" || typeof origin.lng !== "number" || !destination) {
    throw new functions.https.HttpsError("invalid-argument", "Valid origin (lat, lng) and destination required");
  }

  const stagesSnapshot = await db.collection("stages").get();
  const stages: any[] = [];
  stagesSnapshot.forEach(doc => stages.push({ id: doc.id, ...doc.data() }));

  const nearbyStages = stages.filter(s => {
    const stageLat = s.location?._lat ?? s.location?.lat;
    const stageLng = s.location?._lng ?? s.location?.lng;
    if (stageLat == null || stageLng == null) return false;

    const dist = haversineDistance(origin.lat, origin.lng, stageLat, stageLng);
    return dist <= 2.0;
  });

  if (nearbyStages.length === 0) {
    return { journeys: [], message: "No stages found within walking distance" };
  }

  const matatusSnapshot = await db.collection("taxis")
    .where("status", "in", ["LOADING", "EN_ROUTE"])
    .get();
  const matatus: any[] = [];
  matatusSnapshot.forEach(doc => matatus.push({ id: doc.id, ...doc.data() }));

  const journeys: any[] = [];

  for (const startStage of nearbyStages) {
    const stageLat = startStage.location._lat ?? startStage.location.lat;
    const stageLng = startStage.location._lng ?? startStage.location.lng;
    const walkToStart = haversineDistance(origin.lat, origin.lng, stageLat, stageLng) / 5.0;
    const walkMinutes = Math.ceil(walkToStart * 60);

    const relevantMatatus = matatus.filter((m: any) => {
      const route = m.route || [];
      return route.includes(startStage.id);
    });

    for (const matatu of relevantMatatus) {
      const route = matatu.route || [];
      const stageIndex = route.indexOf(startStage.id);
      const remainingRoute = route.slice(stageIndex);

      const destIndex = remainingRoute.findIndex((s: string) =>
        s === destination || stages.find((st: any) => st.id === s)?.name === destination
      );

      if (destIndex !== -1) {
        const fareBoard = matatu.fare_board || {};
        const originFares = fareBoard[startStage.id] || {};
        const fare = originFares[remainingRoute[destIndex]] || 0;
        const travelTime = destIndex * 10;
        const waitTime = matatu.status === "LOADING" ? 5 : 2;

        journeys.push({
          total_time_min: walkMinutes + waitTime + travelTime,
          total_fare: fare,
          legs: [{
            walk_min: walkMinutes,
            stage: startStage.name,
            stage_id: startStage.id,
            matatu_plate: matatu.plate,
            matatu_id: matatu.id,
            departure: "Now",
            arrival: `${travelTime} min`,
            destination: remainingRoute[destIndex],
            fare: fare,
            space: matatu.seat_state === "space_available" ? "🟢 Space Available" :
                   matatu.seat_state === "filling_up" ? "🟠 Filling Up" : "🔴 Full"
          }]
        });
      }
    }
  }

  if (preference === "cheapest") {
    journeys.sort((a, b) => a.total_fare - b.total_fare);
  } else {
    journeys.sort((a, b) => a.total_time_min - b.total_time_min);
  }

  return { journeys: journeys.slice(0, 5) };
});

// ============================================================
// FUNCTION 2: UPDATE MATATU LOCATION
// ============================================================
export const updateMatatuLocation = functions.https.onCall(async (data, context) => {
  const { matatu_id, driver_id, location, speed, heading, seats_available, status } = (data || {}) as Partial<UpdateLocationInput>;

  if (!matatu_id || !location || typeof location.lat !== "number" || typeof location.lng !== "number") {
    throw new functions.https.HttpsError("invalid-argument", "matatu_id and valid location (lat, lng) required");
  }

  const updateData: any = {
    current_location: new admin.firestore.GeoPoint(location.lat, location.lng),
    last_updated: admin.firestore.FieldValue.serverTimestamp()
  };

  if (speed !== undefined) updateData.speed = speed;
  if (heading !== undefined) updateData.heading = heading;
  if (seats_available !== undefined) updateData.seats_available = seats_available;
  if (status !== undefined) updateData.status = status;

  await db.collection("taxis").doc(matatu_id).update(updateData);

  if (driver_id) {
    await db.collection("users").doc(driver_id).update({
      current_location: new admin.firestore.GeoPoint(location.lat, location.lng),
      last_active: admin.firestore.FieldValue.serverTimestamp()
    });
  }

  return { success: true };
});

// ============================================================
// FUNCTION 3: UPDATE SEAT STATUS
// ============================================================
export const updateSeatStatus = functions.https.onCall(async (data, context) => {
  const { matatu_id, seat_state } = (data || {}) as Partial<UpdateSeatStatusInput>;

  const validStates = ["space_available", "filling_up", "full"];
  if (!matatu_id || !seat_state || !validStates.includes(seat_state)) {
    throw new functions.https.HttpsError("invalid-argument", "Valid matatu_id and seat_state required");
  }

  await db.collection("taxis").doc(matatu_id).update({
    seat_state: seat_state,
    seat_state_updated: admin.firestore.FieldValue.serverTimestamp()
  });

  return { success: true };
});

// ============================================================
// FUNCTION 4: CREATE BOOKING
// ============================================================
export const createBooking = functions.https.onCall(async (data, context) => {
  const { passenger_id, matatu_id, origin_stage, destination_stage, seats, fare, booking_type } = (data || {}) as Partial<CreateBookingInput>;

  if (!passenger_id || !matatu_id) {
    throw new functions.https.HttpsError("invalid-argument", "passenger_id and matatu_id required");
  }

  const bookingRef = db.collection("bookings").doc();
  await bookingRef.set({
    passenger_id,
    matatu_id,
    origin_stage: origin_stage || "",
    destination_stage: destination_stage || "",
    seats: seats || 1,
    fare: fare || 0,
    booking_type: booking_type || "individual",
    status: "CONFIRMED",
    payment_status: "UNPAID",
    created_at: admin.firestore.FieldValue.serverTimestamp()
  });

  return { success: true, booking_id: bookingRef.id };
});

// ============================================================
// FUNCTION 5: ADD STAGE we have two functions, one is changed another is for backup
// ============================================================
export const addStage = functions.https.onCall(async (data, context) => {
  const { name, location, added_by } = (data || {}) as Partial<AddStageInput>;

  if (!name || !location || typeof location.lat !== "number" || typeof location.lng !== "number") {
    throw new functions.https.HttpsError("invalid-argument", "name and valid location (lat, lng) required");
  }

  const nearbySnapshot = await db.collection("stages")
    .where("location", ">=", new admin.firestore.GeoPoint(location.lat - 0.0005, location.lng - 0.0005))
    .where("location", "<=", new admin.firestore.GeoPoint(location.lat + 0.0005, location.lng + 0.0005))
    .get();

  if (!nearbySnapshot.empty) {
    const existingDoc = nearbySnapshot.docs[0];
    const currentCount = existingDoc.data().verification_count || 0;
    await existingDoc.ref.update({
      verification_count: currentCount + 1,
      verified: (currentCount + 1) >= 3
    });
    return { success: true, stage_id: existingDoc.id, created: false, verified: (currentCount + 1) >= 3 };
  }

  const stageRef = db.collection("stages").doc();
  await stageRef.set({
    name,
    location: new admin.firestore.GeoPoint(location.lat, location.lng),
    verified: false,
    verification_count: 1,
    added_by: added_by || "anonymous",
    fare_board: {},
    routes: [],
    created_at: admin.firestore.FieldValue.serverTimestamp()
  });

  return { success: true, stage_id: stageRef.id, created: true, verified: false };
});
//ends here
export const addStage1 = functions.https.onCall(async (data, context) => {
  const { name, location, added_by } = (data || {}) as Partial<AddStageInput>;

  if (!name || !location || typeof location.lat !== "number" || typeof location.lng !== "number") {
    throw new functions.https.HttpsError("invalid-argument", "name and valid location (lat, lng) required");
  }

  const nearbySnapshot = await db.collection("stages")
    .where("location", ">=", new admin.firestore.GeoPoint(location.lat - 0.0005, location.lng - 0.0005))
    .where("location", "<=", new admin.firestore.GeoPoint(location.lat + 0.0005, location.lng + 0.0005))
    .get();

  if (!nearbySnapshot.empty) {
    const existingDoc = nearbySnapshot.docs[0];
    const currentCount = existingDoc.data().verification_count || 0;
    await existingDoc.ref.update({
      verification_count: currentCount + 1,
      verified: (currentCount + 1) >= 3
    });
    return { success: true, stage_id: existingDoc.id, created: false };
  }

  const stageRef = db.collection("stages").doc();
  await stageRef.set({
    name,
    location: new admin.firestore.GeoPoint(location.lat, location.lng),
    verified: false,
    verification_count: 1,
    added_by: added_by || "anonymous",
    fare_board: {},
    routes: [],
    created_at: admin.firestore.FieldValue.serverTimestamp()
  });

  return { success: true, stage_id: stageRef.id, created: true };
});

// ============================================================
// HELPER
// ============================================================
function haversineDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLng / 2) * Math.sin(dLng / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}