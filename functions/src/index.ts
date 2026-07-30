import {setGlobalOptions} from "firebase-functions";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();
setGlobalOptions({region: "europe-west1", maxInstances: 10});

const db = admin.firestore();
const messaging = admin.messaging();

interface OrderData {
  buyerId: string;
  vendorId: string;
  dishName: string;
  status: string;
  totalPrice: number;
}

interface NotifConfig {
  recipientId: string;
  title: string;
  body: string;
  role: "buyer" | "vendor";
}

/**
 * Envoie une notification FCM pour une commande.
 * @param {string} orderId - ID de la commande
 * @param {NotifConfig} config - Configuration de la notification
 */
async function sendOrderNotification(
  orderId: string,
  config: NotifConfig
): Promise<void> {
  const userDoc = await db
    .collection("users")
    .doc(config.recipientId)
    .get();
  const fcmToken = userDoc.data()?.fcmToken as string | undefined;
  if (!fcmToken) return;

  try {
    await messaging.send({
      token: fcmToken,
      notification: {
        title: config.title,
        body: config.body,
      },
      data: {
        orderId,
        role: config.role,
        type: "order_status",
      },
      apns: {
        payload: {aps: {sound: "default"}},
      },
      android: {
        notification: {
          sound: "default",
          channelId: "calma_orders",
          priority: "high",
        },
        priority: "high",
      },
    });
  } catch (err) {
    console.error(`FCM error for order ${orderId}:`, err);
  }
}

// ── Nouvelle commande créée → notifier le vendeur ──────────────────────────

export const onOrderCreated = onDocumentCreated(
  "orders/{orderId}",
  async (event) => {
    const data = event.data?.data() as OrderData | undefined;
    if (!data) return;

    await sendOrderNotification(event.params.orderId, {
      recipientId: data.vendorId,
      title: "Nouvelle commande !",
      body: `${data.dishName} — en attente de votre réponse`,
      role: "vendor",
    });
  }
);

// ── Changement de statut → notifier la bonne partie ───────────────────────

export const onOrderStatusChanged = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    const before = event.data?.before.data() as OrderData | undefined;
    const after = event.data?.after.data() as OrderData | undefined;
    if (!before || !after) return;
    if (before.status === after.status) return;

    const orderId = event.params.orderId;
    const {buyerId, vendorId, dishName} = after;

    let config: NotifConfig | null = null;

    switch (after.status) {
    case "accepted":
      config = {
        recipientId: buyerId,
        title: "Commande acceptée 🎉",
        body: `${dishName} — envoyez le paiement pour confirmer`,
        role: "buyer",
      };
      break;

    case "rejected":
      config = {
        recipientId: buyerId,
        title: "Commande refusée",
        body: `${dishName} — le vendeur a refusé votre demande`,
        role: "buyer",
      };
      break;

    case "awaitingConfirmation":
      config = {
        recipientId: vendorId,
        title: "Preuve de paiement reçue",
        body: `${dishName} — vérifiez la capture et confirmez`,
        role: "vendor",
      };
      break;

    case "preparing":
      config = {
        recipientId: buyerId,
        title: "Paiement confirmé !",
        body: `${dishName} est en cours de préparation`,
        role: "buyer",
      };
      break;

    case "ready":
      config = {
        recipientId: buyerId,
        title: "Commande prête ! 🍽️",
        body: `${dishName} — venez récupérer votre commande`,
        role: "buyer",
      };
      break;

    case "cancelled":
      config = {
        recipientId: vendorId,
        title: "Commande annulée",
        body: `${dishName} — l'acheteur a annulé sa commande`,
        role: "vendor",
      };
      break;
    }

    if (config) {
      await sendOrderNotification(orderId, config);
    }
  }
);
