import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessaginBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Mensaje recibido en segundo plano");
  // navgación
}

class NotificationService {
  static final NotificationService instance = NotificationService._init();

  // no llamar al contructor por defecto
  NotificationService._init();

  FirebaseMessaging? _messaging;

  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  Stream<String> get messageStream => _messageController.stream;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isFirebasInitialized = false;
  bool get isFirebassInitialized => _isFirebasInitialized;

  String? _initializationError;
  String? get initializedError => _initializationError;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _isFirebasInitialized = true;
      _messaging = FirebaseMessaging.instance;
      debugPrint("Firebase se inicializó con éxito");

      // Registro de halder para las notificaciones en segundo plano
      FirebaseMessaging.onBackgroundMessage(_firebaseMessaginBackgroundHandler);

      // Obtener el token de FCM
      await getFcmToken();

      // Configurar las notificaciones en primer plano
      _setupForegroundListeners();

      // interacción con las notificaciones
      _setupInteractionListeners();
    } catch (e) {
      _initializationError = e.toString();
      debugPrint(e.toString());
    }
  }

  Future<bool> requestPermission() async {
    if (!_isFirebasInitialized) return false;

    try {
      final settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<String?> getFcmToken() async {
    if (!_isFirebasInitialized) return null;
    try {
      _fcmToken = await _messaging!.getToken();

      debugPrint("FCM token ======> $_fcmToken");

      return _fcmToken;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  void _setupForegroundListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        final content = "${notification.title}: ${notification.body}";
        _messageController.add(content);
      }
    });
  }

  void _setupInteractionListeners() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _messageController.add("Abierto desde push ${notification.title}");
      }
    });
  }

  void dipose() {
    _messageController.close();
  }
}
