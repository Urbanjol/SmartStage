import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

function haversineDistance(
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number
): number {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) *
      Math.sin(dLng / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

export const findMultimodalJourney = functions.https.onCall(async (data, context) => {

const { originLat, originLng, destination } = data as {
  originLat: number;
  originLng: number;
  destination: string;
};
  //const { origin, destination } = data as { origin: string; destination: string };


  if (originLat == null || originLng == null || !destination) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "originLat, originLng, and destination required"
    );
  }
const stagesSnapshot = await db.collection("stages").get();
const stages: any[] = [];
stagesSnapshot.forEach((doc) => stages.push({ id: doc.id, ...doc.data() }));

let nearestStage: any = null;
let nearestDistance = Infinity;

for (const stage of stages) {
  const loc = stage.location || stage.Location;
  if (!loc) continue;

  const lat = loc._lat ?? loc.lat ?? loc._latitude;
  const lng = loc._lng ?? loc.lng ?? loc._longitude;

  if (lat == null || lng == null) continue;

  const dist = haversineDistance(originLat, originLng, lat, lng);

  if (dist < nearestDistance) {
    nearestDistance = dist;
    nearestStage = stage;
  }
}

if (!nearestStage) {
  return { journeys: [] };
}

const origin = nearestStage.name;


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
      const travelTime = (destIndex - originIndex) * 10;
      const fare = taxi.fare_board?.[route[originIndex]]?.[route[destIndex]] || 0;

      journeys.push({
        total_time_min: travelTime,
        total_fare: fare,
        legs: [{
          walk_min: 0,
          stage: route[originIndex],
          stage_id: route[originIndex],
          matatu_plate: taxi.plate,
          matatu_id: taxi.id,
          vehicle_type: taxi.vehicle_type || 'taxi',
          departure: "Now",
          arrival: `${travelTime} min`,
          destination: route[destIndex],
          fare: fare,
          space: taxi.seat_state === "space_available" ? "🟢 Space Available" :
                 taxi.seat_state === "filling_up" ? "🟠 Filling Up" : "🔴 Full"
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

        for (let i = originIndex1; i < route1.length; i++) {
          const commonStage = route1[i];
          const commonIndex2 = route2.findIndex((s: string) => s.toLowerCase() === commonStage.toLowerCase());

          if (commonIndex2 !== -1 && commonIndex2 < destIndex2) {
            const leg1Time = (i - originIndex1) * 10;
            const leg2Time = (destIndex2 - commonIndex2) * 10;
            const transferTime = 10;

            journeys.push({
              total_time_min: leg1Time + transferTime + leg2Time,
              total_fare: 0,
              legs: [
                {
                  walk_min: 0,
                  stage: route1[originIndex1],
                  stage_id: route1[originIndex1],
                  matatu_plate: taxi1.plate,
                  matatu_id: taxi1.id,
                  vehicle_type: taxi1.vehicle_type || 'taxi',
                  departure: "Now",
                  arrival: `${leg1Time} min`,
                  destination: commonStage,
                  fare: 0,
                  space: taxi1.seat_state === "space_available" ? "🟢 Space Available" :
                         taxi1.seat_state === "filling_up" ? "🟠 Filling Up" : "🔴 Full"
                },
                {
                  walk_min: 0,
                  stage: commonStage,
                  stage_id: commonStage,
                  matatu_plate: taxi2.plate,
                  matatu_id: taxi2.id,
                  vehicle_type: taxi2.vehicle_type || 'taxi',
                  departure: `+${leg1Time + transferTime} min`,
                  arrival: `${leg2Time} min`,
                  destination: route2[destIndex2],
                  fare: 0,
                  space: taxi2.seat_state === "space_available" ? "🟢 Space Available" :
                         taxi2.seat_state === "filling_up" ? "🟠 Filling Up" : "🔴 Full"
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