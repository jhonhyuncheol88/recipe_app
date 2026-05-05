import {onRequest} from "firebase-functions/v2/https";
import {logger} from "firebase-functions/v2";
import {defineSecret} from "firebase-functions/params";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();

// RevenueCat 대시보드 → Integrations → Webhooks → Authorization header 에
// 이 secret 을 그대로 입력해야 한다. Bearer 접두사 포함:
//   Authorization: Bearer <REVENUECAT_WEBHOOK_SECRET>
//
// secret 등록:
//   firebase functions:secrets:set REVENUECAT_WEBHOOK_SECRET
const webhookSecret = defineSecret("REVENUECAT_WEBHOOK_SECRET");

// premium 으로 토글하는 이벤트 타입
const PREMIUM_GRANT_TYPES = new Set([
  "INITIAL_PURCHASE",
  "NON_RENEWING_PURCHASE",
  "RENEWAL",
  "PRODUCT_CHANGE",
  "UNCANCELLATION",
]);

// premium 을 회수(false) 하는 이벤트 타입
const PREMIUM_REVOKE_TYPES = new Set([
  "CANCELLATION",
  "EXPIRATION",
  "BILLING_ISSUE",
  "SUBSCRIPTION_PAUSED",
  "REFUND",
]);

interface RevenueCatEvent {
  id?: string;
  type?: string;
  app_user_id?: string;
  original_app_user_id?: string;
  product_id?: string;
  // 기타 필드는 raw 로 보존
  [key: string]: unknown;
}

export const revenueCatWebhook = onRequest(
  {
    secrets: [webhookSecret],
    region: "asia-northeast3",
    cors: false,
  },
  async (req, res): Promise<void> => {
    if (req.method !== "POST") {
      res.status(405).send("method not allowed");
      return;
    }

    // 1. Authorization 검증
    const authHeader = req.header("Authorization") ?? "";
    const expected = `Bearer ${webhookSecret.value()}`;
    if (authHeader !== expected) {
      logger.warn("[revenueCatWebhook] unauthorized", {
        hasHeader: authHeader.length > 0,
      });
      res.status(401).send("unauthorized");
      return;
    }

    // 2. Payload 파싱
    const event: RevenueCatEvent | undefined = req.body?.event;
    if (!event || typeof event !== "object") {
      logger.warn("[revenueCatWebhook] invalid payload");
      res.status(400).send("invalid payload");
      return;
    }

    const appUserId =
      event.app_user_id || event.original_app_user_id || "";
    const eventType = event.type ?? "";
    const productId = event.product_id ?? "";
    const eventId = event.id ?? "";

    if (!appUserId || !eventType || !eventId) {
      logger.warn("[revenueCatWebhook] missing fields", {
        appUserId,
        eventType,
        eventId,
      });
      res.status(400).send("missing fields");
      return;
    }

    // anonymous user ($RCAnonymousID:...) 는 Firebase UID 가 아니므로 무시
    if (appUserId.startsWith("$RCAnonymousID:")) {
      logger.info("[revenueCatWebhook] anonymous skip", {appUserId});
      res.status(200).send("anonymous skipped");
      return;
    }

    // 3. 멱등성: 같은 eventId 가 이미 적재됐으면 무시
    const eventRef = db
      .collection("purchases")
      .doc(appUserId)
      .collection("events")
      .doc(eventId);

    const existing = await eventRef.get();
    if (existing.exists) {
      logger.info("[revenueCatWebhook] duplicate", {eventId});
      res.status(200).send("duplicate");
      return;
    }

    // 4. event 적재
    await eventRef.set({
      id: eventId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      productId,
      type: eventType,
      platform: "webhook",
      raw: event,
    });

    // 5. isPremium 토글
    const grant = PREMIUM_GRANT_TYPES.has(eventType);
    const revoke = PREMIUM_REVOKE_TYPES.has(eventType);

    if (grant || revoke) {
      const userRef = db.collection("users").doc(appUserId);
      const premiumUserRef = db.collection("premium_users").doc(appUserId);

      await userRef.set(
        {
          isPremium: grant,
          premiumUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
          ...(grant && productId ? {premiumProductId: productId} : {}),
        },
        {merge: true}
      );

      if (grant) {
        await premiumUserRef.set({
          uid: appUserId,
          productId: productId || "",
          eventType,
          source: "revenuecat_webhook",
          grantedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        await premiumUserRef.delete().catch((err: unknown) => {
          logger.warn("[revenueCatWebhook] premium_users delete", {err});
        });
      }

      logger.info("[revenueCatWebhook] toggle", {
        appUserId,
        eventType,
        isPremium: grant,
      });
    } else {
      logger.info("[revenueCatWebhook] event recorded only", {
        appUserId,
        eventType,
      });
    }

    res.status(200).send("ok");
  }
);
