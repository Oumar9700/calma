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
  createdAt?: admin.firestore.Timestamp;
  isLateCancellation?: boolean;
  dishId?: string;
  slotId?: string;
  preorderGroupMinimum?: number;
  preorderGroupClosingTime?: admin.firestore.Timestamp;
  isCancelledByTimeout?: boolean;
  isCancelledBySlotDeactivation?: boolean;
  isCancelledByMinimumNotReached?: boolean;
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

    // Incrémenter le compteur précommande (pour affichage acheteur)
    if (
      data.type === "preorder" &&
      !data.slotId &&
      data.dishId &&
      data.preorderDate
    ) {
      const d = data.preorderDate.toDate();
      const mm = String(d.getMonth() + 1).padStart(2, "0");
      const dd = String(d.getDate()).padStart(2, "0");
      const dateStr = `${d.getFullYear()}-${mm}-${dd}`;
      await db
        .collection("preorder_counts")
        .doc(`${data.dishId}__${dateStr}`)
        .set({count: admin.firestore.FieldValue.increment(1)}, {merge: true});
    }

    // Groupe d'achat : notifier le vendeur si le minimum vient d'être atteint
    if (
      data.type === "preorder" &&
      !data.slotId &&
      data.preorderGroupMinimum &&
      data.dishId &&
      data.preorderDate
    ) {
      const minimum = data.preorderGroupMinimum;
      const startOfDay = new Date(data.preorderDate.toDate());
      startOfDay.setHours(0, 0, 0, 0);
      const endOfDay = new Date(startOfDay);
      endOfDay.setDate(endOfDay.getDate() + 1);

      const snap = await db
        .collection("orders")
        .where("dishId", "==", data.dishId)
        .where("type", "==", "preorder")
        .where("status", "==", "pending")
        .get();

      const sameDayCount = snap.docs.filter((doc) => {
        const ts = doc.data().preorderDate as
          | admin.firestore.Timestamp
          | undefined;
        if (!ts) return false;
        const d = ts.toDate();
        return d >= startOfDay && d < endOfDay;
      }).length;

      if (sameDayCount >= minimum) {
        const dateStr = data.preorderDate
          .toDate()
          .toLocaleDateString("fr-FR", {weekday: "long", day: "numeric",
            month: "long"});
        await sendOrderNotification(event.params.orderId, {
          recipientId: data.vendorId,
          title: "Minimum atteint !",
          // eslint-disable-next-line max-len
          body: `${data.dishName} le ${dateStr} — vous pouvez valider le groupe`,
          role: "vendor",
        });
      }
    }

    // Message de bonne conduite lors de la 1ère précommande
    if (data.type === "preorder") {
      const priorOrders = await db
        .collection("orders")
        .where("buyerId", "==", data.buyerId)
        .where("type", "==", "preorder")
        .limit(2)
        .get();
      // priorOrders inclut la commande créée → 1 seul doc = 1ère précommande
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
      // Décrémenter le compteur si c'était une précommande libre (sans créneau)
      if (
        before.type === "preorder" &&
        !before.slotId &&
        before.dishId &&
        before.preorderDate
      ) {
        const d = before.preorderDate.toDate();
        const mm = String(d.getMonth() + 1).padStart(2, "0");
        const dd = String(d.getDate()).padStart(2, "0");
        const dateStr = `${d.getFullYear()}-${mm}-${dd}`;
        await db
          .collection("preorder_counts")
          .doc(`${before.dishId}__${dateStr}`)
          .set(
            {count: admin.firestore.FieldValue.increment(-1)},
            {merge: true}
          );
      }

      if (after.isCancelledByTimeout) {
        config = {
          recipientId: buyerId,
          title: "Commande expiree",
          body: `${dishName} — annulee automatiquement apres 48h sans reponse`,
          role: "buyer",
        };
      } else if (after.isCancelledBySlotDeactivation) {
        config = {
          recipientId: buyerId,
          title: "Creneau annule",
          body: `${dishName} — le vendeur a desactive le creneau`,
          role: "buyer",
        };
      } else if (after.isCancelledByMinimumNotReached) {
        config = {
          recipientId: buyerId,
          title: "Minimum non atteint",
          body:
            `${dishName} — le minimum de précommandes n'a pas été atteint`,
          role: "buyer",
        };
      } else if (after.isLateCancellation) {
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

// ── Timeout commandes abandonnées (48h) ──────────────────────────────────────

export const ordersTimeout = onSchedule(
  {
    schedule: "every 1 hours",
    timeZone: "Europe/Paris",
    region: "europe-west1",
  },
  async () => {
    const cutoff = new Date(Date.now() - 48 * 60 * 60 * 1000);

    const snap = await db
      .collection("orders")
      .where("status", "==", "pending")
      .where(
        "createdAt",
        "<=",
        admin.firestore.Timestamp.fromDate(cutoff)
      )
      .get();

    if (snap.empty) {
      console.log("Timeout: aucune commande a annuler");
      return;
    }

    const batch = db.batch();
    for (const doc of snap.docs) {
      batch.update(doc.ref, {
        status: "cancelled",
        isCancelledByTimeout: true,
      });
    }
    await batch.commit();
    console.log(`Timeout: ${snap.size} commandes annulees automatiquement`);
  }
);

// ── Vérification minimum précommandes simples ────────────────────────────────

interface DishData {
  preorderMinimum?: number;
  preorderClosingHoursBeforeDate?: number;
}

export const preorderMinimumCheck = onSchedule(
  {
    schedule: "every 1 hours",
    timeZone: "Europe/Paris",
    region: "europe-west1",
  },
  async () => {
    // Fenêtre conservatrice : précommandes dans les 48 prochaines heures
    const now = new Date();
    const in48h = new Date(now.getTime() + 48 * 60 * 60 * 1000);

    const snap = await db
      .collection("orders")
      .where("type", "==", "preorder")
      .where("status", "==", "pending")
      .where(
        "preorderDate",
        "<=",
        admin.firestore.Timestamp.fromDate(in48h)
      )
      .get();

    if (snap.empty) return;

    // Grouper par (dishId, preorderDate normalised au jour)
    const groups = new Map<string, typeof snap.docs>();
    for (const doc of snap.docs) {
      const d = doc.data() as OrderData;
      if (!d.dishId || !d.preorderDate) continue;
      const day = d.preorderDate.toDate().toISOString().slice(0, 10);
      const key = `${d.dishId}::${day}`;
      const existing = groups.get(key) ?? [];
      existing.push(doc);
      groups.set(key, existing);
    }

    // Cache des plats déjà chargés
    const dishCache = new Map<string, DishData>();
    const getDish = async (dishId: string): Promise<DishData> => {
      if (dishCache.has(dishId)) {
        return dishCache.get(dishId) as DishData;
      }
      const doc = await db.collection("dishes").doc(dishId).get();
      const data = (doc.data() ?? {}) as DishData;
      dishCache.set(dishId, data);
      return data;
    };

    const batch = db.batch();
    const promises: Promise<void>[] = [];
    let cancelled = 0;

    for (const [, docs] of groups) {
      const sample = docs[0].data() as OrderData;
      if (!sample.dishId || !sample.preorderDate) continue;

      const dish = await getDish(sample.dishId);
      const minimum = dish.preorderMinimum;
      if (!minimum) continue; // pas de minimum défini → rien à faire

      const closingHours = dish.preorderClosingHoursBeforeDate ?? 24;
      const preorderAt = sample.preorderDate.toDate();
      const closingAt = new Date(
        preorderAt.getTime() - closingHours * 60 * 60 * 1000
      );

      if (now < closingAt) continue; // fenêtre pas encore fermée

      if (docs.length >= minimum) {
        // Minimum atteint : rappeler le vendeur s'il n'a pas encore validé
        const sampleData = docs[0].data() as OrderData;
        const dateStr = sampleData.preorderDate
          ?.toDate()
          .toLocaleDateString("fr-FR", {weekday: "long", day: "numeric",
            month: "long"}) ?? "";
        promises.push(
          sendOrderNotification(docs[0].id, {
            recipientId: sampleData.vendorId,
            title: "Rappel : minimum atteint",
            body:
              // eslint-disable-next-line max-len
              `${sampleData.dishName} le ${dateStr} — pensez à valider le groupe`,
            role: "vendor",
          })
        );
        continue;
      }

      // Minimum non atteint : annuler toutes les commandes du groupe
      for (const doc of docs) {
        batch.update(doc.ref, {
          status: "cancelled",
          isCancelledByMinimumNotReached: true,
        });
        cancelled++;
      }
    }

    if (cancelled > 0) await batch.commit();
    if (promises.length > 0) await Promise.all(promises);
    console.log(
      // eslint-disable-next-line max-len
      `Minimum check: ${cancelled} annulees, ${promises.length} rappels vendeur`
    );
  }
);
