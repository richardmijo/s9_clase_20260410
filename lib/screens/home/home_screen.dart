import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clases Móviles - Home'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Seleccione un tema para la clase:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.storage, color: Colors.blue),
            title: const Text('SQLite (Persistencia Local)'),
            subtitle: const Text('Configuración inicial y CRUD básico'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.push('/sqlite'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.orange),
            title: const Text('Firebase Cloud Messaging (FCM)'),
            subtitle: const Text('Notificaciones push'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.push('/fcm'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.map, color: Colors.green),
            title: const Text('flutter_map (Mapas Interactivos)'),
            subtitle: const Text('OpenStreetMap y marcadores'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.push('/map'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cloud_upload, color: Colors.pink),
            title: const Text('Conectarse a un Servidor MinIO'),
            subtitle: const Text('Subida y descarga de archivos'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.push('/minio'),
          ),
        ],
      ),
    );
  }
}
