import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class FcmScreen extends StatefulWidget {
  const FcmScreen({super.key});

  @override
  State<FcmScreen> createState() => _FcmScreenState();
}

class _FcmScreenState extends State<FcmScreen> {
  final NotificationService _notificationService = NotificationService.instance;
  StreamSubscription<String>? _notificationSubscription;

  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    // Suscribirse al Stream del servicio para recibir notificaciones en primer plano (Foreground)
    _notificationSubscription = _notificationService.messageStream.listen((
      message,
    ) {
      if (mounted) {
        // Mostrar el popup inmediatamente al recibir la notificación
        _showNotificationDialog(message);
      }
    });

    // Reintentar obtener el token si es nulo (por si el internet falló al iniciar la app)
    if (_notificationService.fcmToken == null) {
      _notificationService.getFcmToken().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  // Muestra el cuadro de diálogo emergente (Popup) con el mensaje de notificación
  void _showNotificationDialog(String messageContent) {
    // El formato emitido por el servicio es "Título: Cuerpo"
    final parts = messageContent.split(': ');
    final title = parts.isNotEmpty ? parts[0] : 'Nueva Notificación';
    final body = parts.length > 1
        ? parts.sublist(1).join(': ')
        : messageContent;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Solicita permisos nativos de notificación
  Future<void> _requestPermissions() async {
    final granted = await _notificationService.requestPermissions();
    setState(() {
      _isPermissionGranted = granted;
    });
  }

  // Simulación local para probar el comportamiento en clase
  void _simulateIncomingNotification() {
    _showNotificationDialog('Simulado: Notificación de prueba local');
  }

  @override
  Widget build(BuildContext context) {
    // Determinar el mensaje de estado del token con diagnósticos precisos
    final String tokenStatus;
    if (_notificationService.fcmToken != null) {
      tokenStatus = _notificationService.fcmToken!;
    } else if (_notificationService.initializationError != null) {
      tokenStatus = 'Error al inicializar Firebase:\n${_notificationService.initializationError}';
    } else if (_notificationService.isFirebaseInitialized) {
      tokenStatus = 'Firebase inicializado con éxito, pero no se pudo obtener el FCM Token.\n\nDiagnóstico: Verifica que tu emulador o dispositivo tenga conexión a Internet activa y cuente con Google Play Services instalados y actualizados.';
    } else {
      tokenStatus = 'Firebase no inicializado. Asegúrate de colocar tu archivo google-services.json en android/app/ y compilar la app desde cero.';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Messaging (FCM)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase Cloud Messaging (FCM)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Módulo para configurar notificaciones push. Los mensajes en segundo plano llegarán a la barra superior, y en primer plano se mostrarán en un cuadro de diálogo.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // Tarjeta de Permisos
            Card(
              child: ListTile(
                title: const Text('Permisos de Notificación'),
                subtitle: Text(
                  _isPermissionGranted
                      ? 'Permisos: Concedidos'
                      : 'Permisos: No solicitados o denegados',
                ),
                trailing: ElevatedButton(
                  onPressed: _requestPermissions,
                  child: const Text('Solicitar'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Token de FCM
            const Text(
              'FCM Token del Dispositivo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: SelectableText(
                tokenStatus,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            
            if (_notificationService.fcmToken == null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    setState(() {});
                    await _notificationService.getFcmToken();
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar obtener FCM Token'),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Botón de Simulación de Diálogo
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _simulateIncomingNotification,
                icon: const Icon(Icons.flash_on),
                label: const Text('Simular Recepción de Notificación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
