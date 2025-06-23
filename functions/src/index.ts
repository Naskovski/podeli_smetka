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
