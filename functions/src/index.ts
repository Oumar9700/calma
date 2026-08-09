import {setGlobalOptions} from "firebase-functions";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
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
  type?: string;
  totalPrice: number;
  preorderDate?: admin.firestore.Timestamp;
  isLateCancellation?: boolean;
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

    // Message de bonne conduite lors de la 1ère précommande
    if (data.type === "preorder") {
      const priorOrders = await db
        .collection("orders")
        .where("buyerId", "==", data.buyerId)
        .where("type", "==", "preorder")
        .limit(2)
        .get();
      // priorOrders inclut la commande qu'on vient de créer → 1 seul doc = 1ère précommande
      if (priorOrders.size <= 1) {
        await sendOrderNotification(event.params.orderId, {
          recipientId: data.buyerId,
          title: "Ta première précommande",
          body:
            "Le vendeur a investi pour toi. Pense bien a honorer ta commande.",
          role: "buyer",
        });
      }
    }
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
        title: "Commande acceptee",
        body: `${dishName} — envoyez le paiement pour confirmer`,
        role: "buyer",
      };
      break;

    case "rejected":
      config = {
        recipientId: buyerId,
        title: "Commande refusee",
        body: `${dishName} — le vendeur a refuse votre demande`,
        role: "buyer",
      };
      break;

    case "awaitingConfirmation":
      config = {
        recipientId: vendorId,
        title: "Preuve de paiement recue",
        body: `${dishName} — verifiez la capture et confirmez`,
        role: "vendor",
      };
      break;

    case "preparing":
      config = {
        recipientId: buyerId,
        title: "Paiement confirme !",
        body: `${dishName} est en cours de preparation`,
        role: "buyer",
      };
      break;

    case "ready":
      config = {
        recipientId: buyerId,
        title: "Commande prete !",
        body: `${dishName} — venez recuperer votre commande`,
        role: "buyer",
      };
      break;

    case "cancelled":
      if (after.isLateCancellation) {
        // Annulation tardive : notifier le vendeur avec message spécifique
        config = {
          recipientId: vendorId,
          title: "Annulation tardive",
          body:
            `${dishName} — l'acheteur a annule moins de 24h avant la livraison`,
          role: "vendor",
        };
      } else {
        config = {
          recipientId: vendorId,
          title: "Commande annulee",
          body: `${dishName} — l'acheteur a annule sa commande`,
          role: "vendor",
        };
      }
      break;
    }

    if (config) {
      await sendOrderNotification(orderId, config);
    }
  }
);

// ── Rappel 24h avant une précommande ─────────────────────────────────────

export const preorderReminder = onSchedule(
  {
    schedule: "every day 09:00",
    timeZone: "Europe/Paris",
    region: "europe-west1",
  },
  async () => {
    const now = new Date();
    const in23h = new Date(now.getTime() + 23 * 60 * 60 * 1000);
    const in25h = new Date(now.getTime() + 25 * 60 * 60 * 1000);

    const snap = await db
      .collection("orders")
      .where("type", "==", "preorder")
      .where(
        "status",
        "in",
        ["accepted", "awaitingConfirmation", "preparing"]
      )
      .where("preorderDate", ">=", admin.firestore.Timestamp.fromDate(in23h))
      .where("preorderDate", "<=", admin.firestore.Timestamp.fromDate(in25h))
      .get();

    const promises: Promise<void>[] = [];
    for (const doc of snap.docs) {
      const data = doc.data() as OrderData;
      const dateStr = data.preorderDate
        ?.toDate()
        .toLocaleDateString("fr-FR", {weekday: "long", day: "numeric",
          month: "long"}) ?? "";

      // Rappel acheteur
      promises.push(
        sendOrderNotification(doc.id, {
          recipientId: data.buyerId,
          title: "Rappel : commande demain",
          body: `${data.dishName} est prevue pour le ${dateStr}`,
          role: "buyer",
        })
      );

      // Rappel vendeur
      promises.push(
        sendOrderNotification(doc.id, {
          recipientId: data.vendorId,
          title: "Rappel : preparation demain",
          body:
            `${data.dishName} est attendue par un acheteur le ${dateStr}`,
          role: "vendor",
        })
      );
    }

    await Promise.all(promises);
    console.log(`Rappels 24h envoyes : ${snap.size} commandes`);
  }
);
