import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

admin.initializeApp();

export const createUserProfile = functions.region("europe-west1").auth.user().onCreate(async (user) => {
  const uid = user.uid;

  try {
    await admin
      .firestore()
      .collection("userData")
      .doc(uid)
      .set({
        firebaseUID: uid,
        name: user.displayName || "Unknown",
        email: user.email || "",
        photoURL: user.photoURL || "",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    logger.info(`User profile created for ${uid}`);
  } catch (error) {
    logger.error(`Failed to create profile for ${uid}:`, error);
  }
});

export const updateParticipantStatus = functions.region("europe-west1").https.onCall(

  async (data, context) => {
    const { eventId, email, newStatus } = data;

    if (!eventId || !email || !newStatus) {
      throw new functions.https.HttpsError("invalid-argument", "Missing required fields: eventId, email, newStatus");
    }

  const validStatuses = ["invited", "accepted", "declined"];
  if (!validStatuses.includes(newStatus)) {
    throw new Error("Invalid status provided");
  }

  const eventRef = admin.firestore().collection("events").doc(eventId);

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      const snapshot = await transaction.get(eventRef);

      if (!snapshot.exists) {
        throw new Error("Event not found");
      }

      const data = snapshot.data();
      if (!data) {
        throw new Error("Event data is undefined");
      }

      const updatedParticipants = (data.participants || []).map((p: any) => {
        if (p.email === email) {
          return { ...p, status: newStatus };
        }
        return p;
      });

      const statusArrays: Record<string, string[]> = {
        invited: data.invitedParticipantEmails || [],
        accepted: data.acceptedParticipantEmails || [],
        declined: data.declinedParticipantEmails || [],
      };

      for (const status of validStatuses) {
        statusArrays[status] = statusArrays[status].filter((e) => e !== email);
      }

      statusArrays[newStatus].push(email);

      transaction.update(eventRef, {
        participants: updatedParticipants,
        invitedParticipantEmails: statusArrays.invited,
        acceptedParticipantEmails: statusArrays.accepted,
        declinedParticipantEmails: statusArrays.declined,
      });
    });

    logger.info(`Updated status for ${email} in event ${eventId} to ${newStatus}`);
    return { success: true };
  } catch (error: any) {
    logger.error("Failed to update participant status", error);
    throw new Error(error.message || "Unknown error");
  }
});

export const enrichParticipantData = functions
  .region("europe-west1")
  .firestore
  .document("events/{eventId}")
  .onUpdate(async (change, context) => {
    const afterData = change.after.data();
    const eventRef = change.after.ref;

    if (!afterData || !eventRef) {
      logger.warn("No event data or reference.");
      return;
    }

    const invitedEmails: string[] = afterData.invitedParticipantEmails || [];
    const participants: any[] = afterData.participants || [];

    let modified = false;

    for (const email of invitedEmails) {
      const index = participants.findIndex((p) => p.email === email);

      if (index === -1) {
        logger.info(`Email ${email} is in invited list but not in participants array.`);
        continue;
      }

      const participant = participants[index];

      if (participant.user && participant.user.email) continue;

      try {

        const userDataQuery = await admin
                  .firestore()
                  .collection("userData")
                  .where("email", "==", email)
                  .limit(1)
                  .get();

        if (!userDataQuery.empty) {
                const userDoc = userDataQuery.docs[0];
                const userData = userDoc.data();


          participants[index] = {
            ...participant,
            user: userData,
            status: participant.status || "invited",
          };

          modified = true;
          logger.info(`Populated user data for participant ${email}`);
        } else {
          logger.warn(`No user data found for ${email}`);
        }
      } catch (err) {
        logger.error(`Error retrieving user data for ${email}:`, err);
      }
    }

    if (modified) {
      await eventRef.update({ participants });
      logger.info(`Updated participants in event ${eventRef.id}`);
    } else {
      logger.info(`No participant user updates necessary in event ${eventRef.id}`);
    }
  });