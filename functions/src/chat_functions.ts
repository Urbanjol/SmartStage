import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

if (admin.apps.length == 0){
 admin.initializeApp();
}
const db = admin.firestore();

// ============================================================
// TYPE DEFINITIONS
// ============================================================
interface CreateChatInput {
  booking_id: string;
  passenger_id: string;
  driver_id: string;
}

interface SendMessageInput {
  chat_id: string;
  sender_id: string;
  content: string;
  message_type?: string;
}

interface MarkReadInput {
  chat_id: string;
  user_id: string;
}

// ============================================================
// CREATE CHAT ROOM
// ============================================================
export const createChat = functions.https.onCall(async (request) => {
  const data = request.data as CreateChatInput;
  const { booking_id, passenger_id, driver_id } = data;

  if (!booking_id || !passenger_id || !driver_id) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "booking_id, passenger_id, and driver_id required"
    );
  }

  // Check if chat already exists
  const existingChat = await db.collection("chats")
    .where("booking_id", "==", booking_id)
    .get();

  if (!existingChat.empty) {
    return {
      success: true,
      chat_id: existingChat.docs[0].id,
      created: false,
    };
  }

  // Create chat room
  const chatRef = db.collection("chats").doc();
  const chatData = {
    booking_id,
    passenger_id,
    driver_id,
    last_message: "",
    last_message_time: admin.firestore.FieldValue.serverTimestamp(),
    created_at: admin.firestore.FieldValue.serverTimestamp(),
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
    passenger_unread: 0,
    driver_unread: 0,
  };

  await chatRef.set(chatData);

  // Notify both parties
  await db.collection("notifications").add({
    user_id: driver_id,
    title: "New Chat",
    body: "A passenger wants to chat with you",
    type: "CHAT_CREATED",
    booking_id,
    chat_id: chatRef.id,
    read: false,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {
    success: true,
    chat_id: chatRef.id,
    created: true,
  };
});

// ============================================================
// SEND MESSAGE
// ============================================================
export const sendMessage = functions.https.onCall(async (request) => {
  const data = request.data as SendMessageInput;
  const { chat_id, sender_id, content, message_type } = data;

  if (!chat_id || !sender_id || !content) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "chat_id, sender_id, and content required"
    );
  }

  if (content.trim().length === 0) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Message cannot be empty"
    );
  }

  // Verify chat exists
  const chatRef = db.collection("chats").doc(chat_id);
  const chatDoc = await chatRef.get();

  if (!chatDoc.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      "Chat not found"
    );
  }

  const chatData = chatDoc.data();

  // Verify sender is part of chat
  if (sender_id !== chatData?.passenger_id && sender_id !== chatData?.driver_id) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Not authorized to send message in this chat"
    );
  }

  // Create message
  const messageRef = db.collection("messages").doc();
  const messageData = {
    chat_id,
    sender_id,
    content: content.trim(),
    message_type: message_type || "text",
    read: false,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  };

  await messageRef.set(messageData);

  // Update chat
  const receiverId = sender_id === chatData?.passenger_id
    ? chatData?.driver_id
    : chatData?.passenger_id;

  const updateData: any = {
    last_message: content.trim(),
    last_message_time: admin.firestore.FieldValue.serverTimestamp(),
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
  };

  if (receiverId === chatData?.passenger_id) {
    updateData.passenger_unread = admin.firestore.FieldValue.increment(1);
  } else {
    updateData.driver_unread = admin.firestore.FieldValue.increment(1);
  }

  await chatRef.update(updateData);

  // Notify receiver
  await db.collection("notifications").add({
    user_id: receiverId,
    title: "New Message",
    body: content.trim().substring(0, 100),
    type: "CHAT_MESSAGE",
    chat_id,
    booking_id: chatData?.booking_id,
    read: false,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {
    success: true,
    message_id: messageRef.id,
  };
});

// ============================================================
// MARK MESSAGES READ
// ============================================================
export const markMessagesRead = functions.https.onCall(async (request) => {
  const data = request.data as MarkReadInput;
  const { chat_id, user_id } = data;

  if (!chat_id || !user_id) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "chat_id and user_id required"
    );
  }

  const chatRef = db.collection("chats").doc(chat_id);
  const chatDoc = await chatRef.get();

  if (!chatDoc.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      "Chat not found"
    );
  }

  const chatData = chatDoc.data();

  // Reset unread count
  if (user_id === chatData?.passenger_id) {
    await chatRef.update({
      passenger_unread: 0,
    });
  } else if (user_id === chatData?.driver_id) {
    await chatRef.update({
      driver_unread: 0,
    });
  }

  // Mark messages read
  const messagesSnapshot = await db.collection("messages")
    .where("chat_id", "==", chat_id)
    .where("sender_id", "!=", user_id)
    .where("read", "==", false)
    .get();

  const batch = db.batch();
  messagesSnapshot.docs.forEach((doc) => {
    batch.update(doc.ref, { read: true });
  });
  await batch.commit();

  return { success: true };
});

// ============================================================
// GET CHAT DETAILS
// ============================================================
export const getChatDetails = functions.https.onCall(async (request) => {
  const data = request.data as { chat_id: string };
  const { chat_id } = data;

  if (!chat_id) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "chat_id required"
    );
  }

  const chatRef = db.collection("chats").doc(chat_id);
  const chatDoc = await chatRef.get();

  if (!chatDoc.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      "Chat not found"
    );
  }

  return {
    success: true,
    chat: {
      id: chatDoc.id,
      ...chatDoc.data(),
    },
  };
});