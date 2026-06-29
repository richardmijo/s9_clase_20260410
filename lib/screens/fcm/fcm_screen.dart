import 'package:flutter/material.dart';

class FcmScreen extends StatefulWidget {
  const FcmScreen({super.key});

  @override
  State<FcmScreen> createState() => _FcmScreenState();
}

class _FcmScreenState extends State<FcmScreen> {
  final String _mockToken = 'd8A_x2o9SqKz1R...yW9oPzL9T2mN4oPqR7sT8uV9wX0yZ1a2b3c4d5e6';
  bool _isPermissionGranted = false;
  final List<String> _notifications = [];

  void _simulateIncomingNotification() {
    setState(() {
      _notifications.insert(0, 'Notificación de prueba recibida a las ${DateTime.now().toLocal()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Messaging (FCM)'),
      ),
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
              'Aquí configuraremos FCM para recibir notificaciones push en primer plano (foreground) y segundo plano (background).',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Permission Request UI
            Card(
              child: ListTile(
                title: const Text('Permisos de Notificación'),
                subtitle: Text(_isPermissionGranted ? 'Permisos: Concedidos' : 'Permisos: No solicitados'),
                trailing: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isPermissionGranted = !_isPermissionGranted;
                    });
                  },
                  child: Text(_isPermissionGranted ? 'Revocar' : 'Solicitar'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Token display UI
            const Text(
              'FCM Token del Dispositivo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              _mockToken,
              style: const TextStyle(
                fontFamily: 'monospace',
                backgroundColor: Color(0xFFF1F5F9),
              ),
            ),
            const SizedBox(height: 24),

            // Simulate notification action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mensajes Recibidos:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _simulateIncomingNotification,
                  child: const Text('Simular Recepción'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_notifications.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No hay mensajes en la lista.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.message, color: Colors.blue),
                      title: Text(_notifications[index]),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
