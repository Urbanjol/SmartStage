import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import fetch from "node-fetch";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const GOOGLE_PLACES_API_KEY = "AIzaSyAFzb2gSE1rAofZCW01N3bAm4BIA1fdgHc";

export const autocompletePlaces = functions.https.onCall(async (data, context) => {
  const { query } = data as { query: string };

  if (!query || query.length < 3) {
    return { suggestions: [] };
  }

  try {
    const url = `https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${encodeURIComponent(query)}&components=country:ug&key=${GOOGLE_PLACES_API_KEY}`;

    const response = await fetch(url);
    const result = await response.json() as any;

    if (result.status !== "OK") {
      return { suggestions: [] };
    }

    const suggestions = result.predictions.slice(0, 5).map((p: any) => ({
      placeId: p.place_id,
      name: p.structured_formatting?.main_text || p.description,
      address: p.structured_formatting?.secondary_text || "",
    }));

    return { suggestions };
  } catch (e) {
    return { suggestions: [] };
  }
});

export const getPlaceDetails = functions.https.onCall(async (data, context) => {
  const { placeId } = data as { placeId: string };

  if (!placeId) {
    throw new functions.https.HttpsError("invalid-argument", "placeId required");
  }

  try {
    const url = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeId}&fields=geometry,name,formatted_address&key=${GOOGLE_PLACES_API_KEY}`;

    const response = await fetch(url);
    const result = await response.json() as any;

    if (result.status !== "OK") {
      return { lat: null, lng: null };
    }

    return {
      lat: result.result.geometry.location.lat,
      lng: result.result.geometry.location.lng,
      name: result.result.name,
      address: result.result.formatted_address,
    };
  } catch (e) {
    return { lat: null, lng: null };
  }
});