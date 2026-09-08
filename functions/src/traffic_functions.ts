import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import fetch from "node-fetch";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

//const db = admin.firestore();

const GEMINI_API_KEY = "AQ.Ab8RN6KC89WrKHykYhJwTkMMaXAhxugvvXN77i9laQosZWKjpQ"; // Replace with your key

export const getTrafficForRoute = functions.https.onCall(async (data, context) => {
  const { route } = data as { route: string[] };

  if (!route || route.length < 2) {
    throw new functions.https.HttpsError("invalid-argument", "Route required");
  }

  //const road = `${route[0]} to ${route[route.length - 1]}`;

  const prompt = `
    What is the current traffic condition on the route from ${route[0]} to ${route[route.length - 1]} in Uganda?
    Consider the stages: ${route.join(", ")}.
    Return ONLY a JSON object with:
    {
      "condition": "Light" or "Moderate" or "Heavy",
      "estimated_delay_minutes": 5,
      "summary": "Brief traffic summary"
    }
  `;

  try {
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text: prompt,
                },
              ],
            },
          ],
        }),
      }
    );

    const result = await response.json() as any;
    const text = result.candidates?.[0]?.content?.parts?.[0]?.text || "{}";

    const match = text.match(/\{[\s\S]*\}/);
    const trafficData = match ? JSON.parse(match[0]) : {
      condition: "Unknown",
      estimated_delay_minutes: 0,
      summary: "No traffic data",
    };

    return trafficData;
  } catch (e) {
    return {
      condition: "Unknown",
      estimated_delay_minutes: 0,
      summary: "Traffic unavailable",
    };
  }
});