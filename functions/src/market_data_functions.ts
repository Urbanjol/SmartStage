import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import fetch from "node-fetch";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

const GEMINI_API_KEY = "AQ.Ab8RN6KC89WrKHykYhJwTkMMaXAhxugvvXN77i9laQosZWKjpQ"; // Replace with your key

export const fetchMarketData = functions.pubsub
  .schedule("0 * * * *") //changed to hourly
  .timeZone("Africa/Kampala")
  .onRun(async () => {
    try {
      const prompt = `
        Give me today's fuel prices in Uganda for Shell, TotalEnergies, Stabex.
        Include petrol, diesel, kerosene.

        Also give me current traffic conditions on these roads:
        Kampala-Jinja Road, Entebbe Road, Masaka Road, Northern Bypass.

        For traffic, use: Light, Moderate, or Heavy.

        Return ONLY a JSON object with this structure:
        {
          "fuel": [
            {"company": "Shell", "petrol": 5200, "diesel": 5000, "kerosene": 4500},
            {"company": "TotalEnergies", "petrol": 5150, "diesel": 4950, "kerosene": 4450},
            {"company": "Stabex", "petrol": 5100, "diesel": 4900, "kerosene": 4400}
          ],
          "traffic": [
            {"road": "Kampala-Jinja Road", "condition": "Heavy"},
            {"road": "Entebbe Road", "condition": "Moderate"},
            {"road": "Masaka Road", "condition": "Light"},
            {"road": "Northern Bypass", "condition": "Moderate"}
          ],
          "news": [
            "Fuel prices rise by 2%",
            "Heavy traffic on Jinja Road"
          ]
        }
      `;

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
      const data = match ? JSON.parse(match[0]) : { fuel: [], traffic: [], news: [] };

      await db.collection("market_data").doc("latest").set({
        fuel: data.fuel || [],
        traffic: data.traffic || [],
        news: data.news || [],
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      console.error("Market data fetch failed:", e);
      return null;
    }
  });