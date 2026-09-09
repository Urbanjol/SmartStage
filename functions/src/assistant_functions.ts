import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import fetch from "node-fetch";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

const GROQ_API_KEY = "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";
//const GEMINI_API_KEY = "AIzaSy..."; // Replace with your key if needed

// ============================================================
// ROUTE GRAPH HELPERS
// ============================================================

async function storeRouteEdges(route: string[]) {
  for (let i = 0; i < route.length - 1; i++) {
    const from = route[i];
    const to = route[i + 1];

    const edgeId = `${from}_${to}`.replace(/\s+/g, '_').toLowerCase();

    const edgeRef = db.collection("route_graph").doc(edgeId);

    const edgeDoc = await edgeRef.get();

    if (edgeDoc.exists) {
      await edgeRef.update({
        count: admin.firestore.FieldValue.increment(1),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      await edgeRef.set({
        from: from,
        to: to,
        count: 1,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
}

async function suggestFromGraph(origin: string, destination: string) {
  const route = [origin];
  let current = origin;

  for (let i = 0; i < 20; i++) {
    const edgesSnapshot = await db.collection("route_graph")
      .where("from", "==", current)
      .orderBy("count", "desc")
      .limit(10)
      .get();

    if (edgesSnapshot.empty) break;

    let next: string | null = null;

    for (const doc of edgesSnapshot.docs) {
      const to = doc.data().to as string;

      if (to === destination) {
        next = to;
        break;
      }

      const nextEdges = await db.collection("route_graph")
        .where("from", "==", to)
        .limit(1)
        .get();

      if (!nextEdges.empty) {
        next = to;
        break;
      }
    }

    if (next == null) break;

    route.push(next);
    current = next;

    if (current === destination) break;
  }

  if (route.length > 1 && route[route.length - 1] === destination) {
    return route;
  }

  return null;
}

// ============================================================
// SMARTSTAGE ASSISTANT
// ============================================================

export const smartAssistant = functions.https.onCall(async (data, ctx) => {
  const question = data.question as string;

  if (!question) {
    throw new functions.https.HttpsError("invalid-argument", "Question required");
  }

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
- Fare = Sente or Ffeeri
- Where = Wa
- How much = Sente mmeka
- I want = Njagala
- Book for me = Nkubukire`
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

// ============================================================
// AUTO FILL ROUTE
// ============================================================

export const autoFillRoute = functions.https.onCall(async (data, context) => {
  const { origin, destination } = data as { origin: string; destination: string };

  if (!origin || !destination) {
    throw new functions.https.HttpsError("invalid-argument", "Origin and destination required");
  }

  // Try route graph first
  try {
    const graphRoute = await suggestFromGraph(origin, destination);

    if (graphRoute) {
      return { route: graphRoute, source: "graph" };
    }
  } catch (e) {
    // Continue
  }

  // Check ai_routes
  try {
    const existingSnapshot = await db.collection("ai_routes")
      .where("origin", "==", origin)
      .where("destination", "==", destination)
      .limit(1)
      .get();

    if (!existingSnapshot.empty) {
      const existingDoc = existingSnapshot.docs[0];
      const existingRoute = existingDoc.data().stages;

      await existingDoc.ref.update({
        used_count: admin.firestore.FieldValue.increment(1)
      });

      return { route: existingRoute, source: "stored" };
    }
  } catch (e) {
    // Continue
  }

  // Fallback to Groq
  const prompt = `
    You know Ugandan taxi routes.
    A taxi is going from ${origin} to ${destination}.
    List the major taxi stages along the way in order.
    Include the origin first and destination last.
    Return ONLY a JSON array of stage names.
    Example: ["Mukono", "Kireka", "Bweyogere", "Old Taxi Park"]
  `;

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
            content: "You are SmartStage route assistant. You know Ugandan roads and taxi stages."
          },
          {
            role: "user",
            content: prompt
          }
        ],
        temperature: 0.3,
        max_tokens: 500,
      }),
    });

    const result = await response.json() as any;
    const content = result.choices?.[0]?.message?.content || "[]";

    const match = content.match(/\[[\s\S]*\]/);
    const route = match ? JSON.parse(match[0]) : [origin, destination];

    try {
      await db.collection("ai_routes").add({
        origin: origin,
        destination: destination,
        stages: route,
        generated_by: "groq",
        used_count: 1,
        verified_count: 0,
        created_at: admin.firestore.FieldValue.serverTimestamp()
      });
    } catch (e) {
      // Silently fail
    }

    try {
      await storeRouteEdges(route);
    } catch (e) {
      // Silently fail
    }

    return { route, source: "groq" };
  } catch (e) {
    return { route: [origin, destination], source: "fallback" };
  }
});