import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Función obligatoria fuera de cualquier clase (Top-Level Function)
// para manejar las notificaciones cuando la app está en segundo plano o cerrada.
// Se añade la anotación pragma para evitar que el compilador descarte esta función.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inicializa Firebase para poder interactuar con los servicios dentro de este hilo aislado.
  await Firebase.initializeApp();
  debugPrint("Mensaje recibido en segundo plano: ${message.messageId}");
}

class NotificationService {
  // Instancia singleton para acceder al servicio en toda la aplicación
  static final NotificationService instance = NotificationService._init();

  NotificationService._init();

  FirebaseMessaging? _messaging;

  // StreamController para propagar las notificaciones recibidas a la UI
  final StreamController<String> _messageController = StreamController<String>.broadcast();
  Stream<String> get messageStream => _messageController.stream;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isFirebaseInitialized = false;
  bool get isFirebaseInitialized => _isFirebaseInitialized;

  String? _initializationError;
  String? get initializationError => _initializationError;

  // Inicialización principal de Firebase y FCM
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _isFirebaseInitialized = true;
      _messaging = FirebaseMessaging.instance;
      debugPrint("Firebase inicializado con éxito.");

      // 2. Registrar el manejador de segundo plano
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Obtener el token de FCM del dispositivo para pruebas de push
      await getFcmToken();

      // 4. Configurar escuchas para primer plano (Foreground)
      _setupForegroundListeners();

      // 5. Configurar apertura desde segundo plano
      _setupInteractionListeners();
    } catch (e) {
      _initializationError = e.toString();
      // Atajamos el error para evitar que la aplicación se caiga en clase si
      // los estudiantes aún no colocan su archivo google-services.json
      debugPrint("ADVERTENCIA: Firebase no pudo inicializarse. Asegúrate de colocar el archivo google-services.json: $e");
    }
  }

  // Solicita permisos de notificación al usuario (Android 13+ e iOS)
  Future<bool> requestPermissions() async {
    if (!_isFirebaseInitialized) return false;

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

      debugPrint('Estado de los permisos otorgado: ${settings.authorizationStatus}');
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint("Error al solicitar permisos: $e");
      return false;
    }
  }

  // Obtiene el token FCM único para este dispositivo
  Future<String?> getFcmToken() async {
    if (!_isFirebaseInitialized) return null;

    try {
      _fcmToken = await _messaging!.getToken();
      debugPrint("FCM Token obtenido: $_fcmToken");
      return _fcmToken;
    } catch (e) {
      debugPrint("Error al obtener FCM Token: $e");
      return null;
    }
  }

  // Escucha mensajes entrantes cuando la app está abierta en pantalla (Foreground)
  void _setupForegroundListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Mensaje recibido en primer plano (Foreground)!');
      
      final notification = message.notification;
      if (notification != null) {
        final content = "${notification.title}: ${notification.body}";
        // Emitir el contenido de la notificación al Stream para que la UI se actualice
        _messageController.add(content);
      }
    });
  }

  // Escucha las interacciones cuando el usuario presiona la notificación push
  void _setupInteractionListeners() {
    // Si la app estaba en segundo plano y se abre mediante un click en la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('El usuario abrió la app desde una notificación!');
      final notification = message.notification;
      if (notification != null) {
        _messageController.add("Abierto desde push: ${notification.title}");
      }
    });
  }

  // Cierra el StreamController cuando no se necesite
  void dispose() {
    _messageController.close();
  }
}
