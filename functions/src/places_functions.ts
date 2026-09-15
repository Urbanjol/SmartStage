import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import fetch from "node-fetch";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

//const db = admin.firestore();

const GOOGLE_PLACES_API_KEY = "AIzaSyAFzb2gSE1rAofZCW01N3bAm4BIA1fdgHc";

export const searchPlaces = functions.https.onCall(async (data, context) => {
  const { query } = data as { query: string };

  if (!query) {
    throw new functions.https.HttpsError("invalid-argument", "Query required");
  }

  try {
    const url = `https://maps.googleapis.com/maps/api/place/textsearch/json?query=${encodeURIComponent(query)},Uganda&key=${GOOGLE_PLACES_API_KEY}`;

    const response = await fetch(url);
    const result = await response.json() as any;

    if (result.status !== "OK") {
      return { places: [] };
    }

    const places = result.results.slice(0, 10).map((place: any) => {
      let photoUrl = "";

      if (place.photos && place.photos.length > 0) {
        const photoReference = place.photos[0].photo_reference;
        photoUrl = `https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photoReference}&key=${GOOGLE_PLACES_API_KEY}`;
      }

      return {
        name: place.name,
        address: place.formatted_address,
        rating: place.rating || 0,
        photoUrl: photoUrl,
        lat: place.geometry.location.lat,
        lng: place.geometry.location.lng,
      };
    });

    return { places };
  } catch (e) {
    return { places: [] };
  }
});