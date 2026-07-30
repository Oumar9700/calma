import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';

// Top-level : requis par FCM pour les messages background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase est déjà initialisé par l'app principale
}

class NotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Référence au router pour la navigation depuis tap
  GoRouter? _router;

  static const _channelId = 'calma_orders';
  static const _channelName = 'Commandes Calma';

  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  void attachRouter(GoRouter router) => _router = router;

  Future<void> initialize() async {
    // Handler background (avant initialize)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Canal Android
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.high,
            playSound: true,
          ));
    }

    // Init flutter_local_notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Demande de permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground : affichage local
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // Tap notification quand app en background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessageTap);

    // Tap notification quand app terminée
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      // Délai pour laisser le router s'initialiser
      await Future.delayed(const Duration(milliseconds: 500));
      _handleRemoteMessageTap(initial);
    }
  }

  // Appelé après connexion réussie
  Future<void> saveToken(String uid) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _updateToken(uid, token);
    }
    _messaging.onTokenRefresh.listen((newToken) => _updateToken(uid, newToken));
  }

  Future<void> _updateToken(String uid, String token) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }

  // Supprime le token à la déconnexion (évite les notifs fantômes)
  Future<void> clearToken(String uid) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({'fcmToken': FieldValue.delete()});
    await _messaging.deleteToken();
  }

  // ── Affichage local (foreground) ────────────────────────────────────────

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;

    await _localNotifications.show(
      message.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: _buildPayload(message.data),
    );
  }

  // ── Navigation ──────────────────────────────────────────────────────────

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    _navigate(payload);
  }

  void _handleRemoteMessageTap(RemoteMessage message) {
    _navigate(_buildPayload(message.data));
  }

  // Payload = "buyer:{orderId}" ou "vendor"
  String _buildPayload(Map<String, dynamic> data) {
    final orderId = data['orderId'] as String? ?? '';
    final role = data['role'] as String? ?? 'buyer';
    return '$role:$orderId';
  }

  void _navigate(String payload) {
    if (_router == null) return;
    final parts = payload.split(':');
    if (parts.length < 2) return;
    final role = parts[0];
    final orderId = parts[1];

    if (role == 'vendor') {
      _router!.go(AppRoutes.vendorOrders);
    } else if (orderId.isNotEmpty) {
      _router!.go(AppRoutes.orderDetail.replaceFirst(':orderId', orderId));
    }
  }
}
