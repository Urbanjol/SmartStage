import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

export const findMultimodalJourney = functions.https.onCall(async (data, context) => {
  const { origin, destination } = data as { origin: string; destination: string };

  if (!origin || !destination) {
    throw new functions.https.HttpsError("invalid-argument", "Origin and destination required");
  }

  // Get all active taxis
  const taxisSnapshot = await db.collection("taxis")
    .where("status", "in", ["LOADING", "EN_ROUTE"])
    .get();

  const taxis: any[] = [];
  taxisSnapshot.forEach(doc => taxis.push({ id: doc.id, ...doc.data() }));

  const journeys: any[] = [];

  // Direct journeys
  for (const taxi of taxis) {
    const route = taxi.route || [];

    const originIndex = route.findIndex((s: string) => s.toLowerCase() === origin.toLowerCase());
    const destIndex = route.findIndex((s: string) => s.toLowerCase() === destination.toLowerCase());

    if (originIndex !== -1 && destIndex !== -1 && destIndex > originIndex) {
      journeys.push({
        type: "direct",
        total_time_min: (destIndex - originIndex) * 10,
        total_fare: taxi.fare_board?.[route[originIndex]]?.[route[destIndex]] || 0,
        legs: [{
          vehicle_type: taxi.vehicle_type || 'taxi',
          plate: taxi.plate,
          from: route[originIndex],
          to: route[destIndex],
          seats_available: taxi.seats_available,
        }]
      });
    }
  }

  // Multi-modal: find connection
  if (journeys.length === 0) {
    for (const taxi1 of taxis) {
      const route1 = taxi1.route || [];
      const originIndex1 = route1.findIndex((s: string) => s.toLowerCase() === origin.toLowerCase());

      if (originIndex1 === -1) continue;

      for (const taxi2 of taxis) {
        if (taxi1.id === taxi2.id) continue;

        const route2 = taxi2.route || [];
        const destIndex2 = route2.findIndex((s: string) => s.toLowerCase() === destination.toLowerCase());

        if (destIndex2 === -1) continue;

        // Find common stage
        for (let i = originIndex1; i < route1.length; i++) {
          const commonStage = route1[i];
          const commonIndex2 = route2.findIndex((s: string) => s.toLowerCase() === commonStage.toLowerCase());

          if (commonIndex2 !== -1 && commonIndex2 < destIndex2) {
            const leg1Time = (i - originIndex1) * 10;
            const leg2Time = (destIndex2 - commonIndex2) * 10;
            const transferTime = 10;

            journeys.push({
              type: "multimodal",
              total_time_min: leg1Time + transferTime + leg2Time,
              total_fare: 0,
              legs: [
                {
                  vehicle_type: taxi1.vehicle_type || 'taxi',
                  plate: taxi1.plate,
                  from: route1[originIndex1],
                  to: commonStage,
                  seats_available: taxi1.seats_available,
                },
                {
                  vehicle_type: taxi2.vehicle_type || 'taxi',
                  plate: taxi2.plate,
                  from: commonStage,
                  to: route2[destIndex2],
                  seats_available: taxi2.seats_available,
                }
              ]
            });

            break;
          }
        }
      }
    }
  }

  journeys.sort((a, b) => a.total_time_min - b.total_time_min);

  return { journeys: journeys.slice(0, 5) };
});