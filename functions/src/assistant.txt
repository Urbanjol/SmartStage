import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import fetch from "node-fetch";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();
const GROQ_API_KEY = "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";

export const smartAssistant = functions.https.onCall(async (data, ctx) => {
  const question = data.question as string;

  if (!question) {
    throw new functions.https.HttpsError("invalid-argument", "Question required");
  }

  // Fetch relevant data
  let contextData = "";

  try {
    const taxisSnapshot = await db.collection("taxis").limit(5).get();

    if (!taxisSnapshot.empty) {
      contextData += "Available taxis:\n";
      taxisSnapshot.forEach(doc => {
        const taxi = doc.data();
        contextData += `- ${taxi.plate || 'Unknown'}: ${taxi.seat_state || 'unknown'}, route: ${(taxi.route || []).join(', ')}\n`;
      });
    }

    const stagesSnapshot = await db.collection("stages").limit(5).get();

    if (!stagesSnapshot.empty) {
      contextData += "\nStages:\n";
      stagesSnapshot.forEach(doc => {
        const stage = doc.data();
        contextData += `- ${stage.name || 'Unknown'}\n`;
      });
    }
  } catch (e) {
    contextData = "No live data available.";
  }

  // Send to Groq
  try {
    const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${GROQ_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "qwen/qwen3.6-27b",
        messages: [
          {
            role: "system",
            content: `You are Stage AI, the SmartStage assistant.
You help passengers and drivers in Uganda.
You understand English and Luganda.
Always respond in the same language as the user.
Be warm, helpful, and concise.

Luganda terms:
- Taxi = Taxi or Kkoopi
- Stage = Siteegi
- Fare = Sente or Omuwendo
- Where = Wa or Ewa
- How much = Sente mmeka
- I want = Njagala
- Book for me = Mbukiingira`
          },
          {
            role: "user",
            content: `Question: ${question}\n\nLive data:\n${contextData}`
          }
        ],
        temperature: 0.3,
        max_tokens: 1000,
      }),
    });

    const result = await response.json() as any;
    const answer = result.choices?.[0]?.message?.content || "Sorry, I could not process that.";

    return { answer };

  } catch (e) {
    return { answer: "Sorry, the assistant is temporarily unavailable." };
  }
});