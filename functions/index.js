/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 * //const {onRequest} = require("firebase-functions/v2/https");
* //const logger = require("firebase-functions/logger");
 */


const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.onCreateNotifArtist = functions.firestore
    .document("/feed/{userId}/feedItems/{feedItem}")
    .onCreate(async (snapshot, context) => {
      console.log("Notif created", snapshot.data());
      // 1) Get user connected to the feed
      const userId = context.params.userId;
      const userRef = admin.firestore().doc(`users/${userId}`);
      const doc = await userRef.get();
      // 2) Once we have user, check if they have a notification token
      const androidNotificationToken = doc.data().androidNotificationToken;
      const feedItem = snapshot.data();
      if (androidNotificationToken) {
        // send notif
        sendNotif(androidNotificationToken, feedItem, 0);
      } else {
        console.log("No token, can't send notif");
      }
      // 1a) Getting sender details
      const userId2 = feedItem.notifId;
      const userRef2 = admin.firestore().doc(`users/${userId2}`);
      const doc2 = await userRef2.get();
      const androidNotificationToken2 = doc2.data().androidNotificationToken;
      if (androidNotificationToken2) {
        // send notif
        sendNotif(androidNotificationToken2, feedItem, 1);
      } else {
        console.log("No token, can't send notif");
      }
      /**
      * A brief description of the function.
      *
      * @param {type} androidNotificationToken - Description of the parameter.
      * @param {type} feedItem - Description of the parameter.
      * @param {type} x - Description of the parameter.
      */
      function sendNotif(androidNotificationToken, feedItem, x) {
        let body;
        // 3) Swtich body values based off of notification type
        if (x==1) {
          switch (feedItem.status) {
            case "Order Placed":
              body = `Hi ${feedItem.cus}, Your order has been placed`;
              break;
            case "Order Confirmed":
              body = `Hi ${feedItem.cus}, Your order has been confirmed`;
              break;
            case "In Progress":
              body = `Hi ${feedItem.cus}, Your order is a work in progress`;
              break;
            case "Dispatched":
              body = `Hi ${feedItem.cus}, Your order has been dispatched`;
              break;
            case "Delivered":
              body = `Hi ${feedItem.cus}, Your order has been delivered`;
              break;
            case "Cancelled":
              body = `Hi ${feedItem.cus}, Your order has been cancelled`;
              break;

            default:
              break;
          }
        } else {
          switch (feedItem.status) {
            case "Order Placed":
              body = `Hi Admin, ${feedItem.cus} placed an order`;
              break;
            case "Order Confirmed":
              body = `Hi Admin, ${feedItem.cus}'s order is confirmed`;
              break;
            case "In Progress":
              body = `Hi Admin, ${feedItem.cus}'s order is in progress`;
              break;
            case "Dispatched":
              body = `Hi Admin, ${feedItem.cus}'s order is dispatched`;
              break;
            case "Delivered":
              body = `Hi Admin, ${feedItem.cus}'s order has been delivered`;
              break;
            case "Cancelled":
              body = `Hi Admin, ${feedItem.cus}'s order has been cancelled`;
              break;

            default:
              break;
          }
        }


        // 4) create message for the push notif

        const message = {
          notification: {body},
          token: androidNotificationToken,
          data: {recipient: (x==1)? userId2 : userId},
        };

        // 5) send message with admin.messaging()

        admin.messaging().send(message).then( (response) => {
          // Response is a  message ID string
          console.log("Succesfully sent message", response);
        }).catch((error) => {
          console.log("Error sending message", error);
        });
      }
    });
