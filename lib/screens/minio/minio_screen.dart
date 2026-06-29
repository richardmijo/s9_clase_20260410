import 'dart:async';
import 'package:flutter/material.dart';

class MinioScreen extends StatefulWidget {
  const MinioScreen({super.key});

  @override
  State<MinioScreen> createState() => _MinioScreenState();
}

class _MinioScreenState extends State<MinioScreen> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _selectedFileName;
  Timer? _simulationTimer;

  final List<String> _uploadedFiles = [
    'clase_tema1_sqlite.pdf',
    'avatar_usuario_12.png',
  ];

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _selectMockFile() {
    setState(() {
      _selectedFileName = 'uide_ejercicio_movil.zip';
      _uploadProgress = 0.0;
      _isUploading = false;
    });
  }

  void _simulateUpload() {
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un archivo primero.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        if (_uploadProgress < 1.0) {
          _uploadProgress += 0.1;
        } else {
          timer.cancel();
          _isUploading = false;
          _uploadedFiles.insert(0, _selectedFileName!);
          _selectedFileName = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Archivo subido exitosamente a MinIO!')),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexión a MinIO'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conectarse a un Servidor MinIO',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aprenderemos a subir y descargar archivos mediante un cliente compatible con el almacenamiento S3 de MinIO.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // Select and upload file area
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _selectMockFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Seleccionar Archivo (Simulado)'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFileName ?? 'Ningún archivo seleccionado',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    if (_isUploading) ...[
                      LinearProgressIndicator(value: _uploadProgress),
                      const SizedBox(height: 12),
                    ],

                    ElevatedButton(
                      onPressed: _isUploading ? null : _simulateUpload,
                      child: const Text('Subir Archivo'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Files in Bucket list
            const Text(
              'Archivos en el Servidor (Bucket):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _uploadedFiles.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
                    title: Text(_uploadedFiles[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.download, color: Colors.blue),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Descargando archivo: ${_uploadedFiles[index]} (Simulado)')),
                        );
                      },
                    ),
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
