import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:path_provider/path_provider.dart';
import '../../services/minio_service.dart';

class MinioScreen extends StatefulWidget {
  const MinioScreen({super.key});

  @override
  State<MinioScreen> createState() => _MinioScreenState();
}

class _MinioScreenState extends State<MinioScreen> {
  final MinioService _minioService = MinioService.instance;

  // Controladores de texto para credenciales
  final _endpointController = TextEditingController(text: 's3.uidehub.tech');
  final _accessKeyController = TextEditingController(text: 'admin_uidehub');
  final _secretKeyController = TextEditingController(
    text: 'gOggAJFliVtNFlX7aibcb/MCaVrpN/cQtLkUMPLaUlU=',
  );
  final _bucketController = TextEditingController(text: 'pruebas');

  bool _isUploading = false;
  bool _isLoadingFiles = false;
  String? _selectedFileName;
  String? _selectedFilePath;

  List<Map<String, dynamic>> _serverFiles = [];
  String? _previewPath;
  String? _previewType;

  @override
  void initState() {
    super.initState();
    // Si ya fue inicializado previamente, cargamos archivos
    if (_minioService.isInitialized) {
      _refreshFiles();
    }
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _accessKeyController.dispose();
    _secretKeyController.dispose();
    _bucketController.dispose();
    super.dispose();
  }

  // Inicializa el servicio
  void _connectMinio() {
    if (_secretKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa tu clave secreta de MinIO.'),
        ),
      );
      return;
    }

    try {
      _minioService.initialize(
        endPoint: _endpointController.text.trim(),
        accessKey: _accessKeyController.text.trim(),
        secretKey: _secretKeyController.text.trim(),
        bucketName: _bucketController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente MinIO inicializado con éxito.')),
      );
      _refreshFiles();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al conectar: $e')));
    }
  }

  // Refresca la lista de archivos reales en MinIO
  Future<void> _refreshFiles() async {
    if (!_minioService.isInitialized) return;

    setState(() => _isLoadingFiles = true);
    try {
      final files = await _minioService.listObjects();
      setState(() {
        _serverFiles = files;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al obtener archivos: $e')));
    } finally {
      setState(() => _isLoadingFiles = false);
    }
  }

  // Permite seleccionar un archivo real usando file_picker
  Future<void> _selectFile() async {
    try {
      final result = await fp.FilePicker.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFileName = result.files.single.name;
          _selectedFilePath = result.files.single.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar archivo: $e')),
      );
    }
  }

  // Sube el archivo seleccionado a la VPS
  Future<void> _uploadFile() async {
    if (_selectedFileName == null || _selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un archivo primero.'),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      await _minioService.uploadFile(_selectedFileName!, _selectedFilePath!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Archivo subido exitosamente a MinIO VPS!'),
        ),
      );
      setState(() {
        _selectedFileName = null;
        _selectedFilePath = null;
      });
      _refreshFiles(); // Refrescar lista
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir archivo: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // Descarga el archivo de forma real y lo guarda localmente en el directorio de descargas/temporal
  Future<void> _downloadFile(String objectName) async {
    try {
      final directory = await getTemporaryDirectory();
      final localSavePath = '${directory.path}/$objectName';

      await _minioService.downloadFile(objectName, localSavePath);

      // Identificar extensión para la vista previa
      final lowerName = objectName.toLowerCase();
      if (lowerName.endsWith('.png') ||
          lowerName.endsWith('.jpg') ||
          lowerName.endsWith('.jpeg') ||
          lowerName.endsWith('.gif') ||
          lowerName.endsWith('.webp')) {
        setState(() {
          _previewPath = localSavePath;
          _previewType = 'image';
        });
      } else if (lowerName.endsWith('.mp4') ||
          lowerName.endsWith('.mov') ||
          lowerName.endsWith('.avi')) {
        setState(() {
          _previewPath = localSavePath;
          _previewType = 'video';
        });
      } else {
        setState(() {
          _previewPath = null;
          _previewType = null;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Descargado: $objectName\nGuardado en: $localSavePath'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al descargar archivo: $e')));
    }
  }

  // Elimina un archivo de forma real del bucket
  Future<void> _deleteFile(String objectName) async {
    try {
      await _minioService.deleteFile(objectName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo "$objectName" eliminado.')),
      );
      _refreshFiles();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar archivo: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexión a MinIO VPS'),
        actions: [
          if (_minioService.isInitialized)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshFiles,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurar Conexión MinIO',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Formulario de Credenciales
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _endpointController,
                      decoration: const InputDecoration(
                        labelText: 'S3 API Endpoint',
                        hintText: 's3.uidehub.tech',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _accessKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Access Key',
                        hintText: 'admin_uidehub',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _secretKeyController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Secret Key (VPS)',
                        hintText: 'Clave secreta asignada',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bucketController,
                      decoration: const InputDecoration(
                        labelText: 'Bucket Name',
                        hintText: 'pruebas',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: _connectMinio,
                        icon: const Icon(Icons.cloud_queue),
                        label: const Text('Conectar & Sincronizar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (!_minioService.isInitialized) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Ingresa las credenciales de tu VPS de MinIO arriba para habilitar la subida y descarga de archivos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Área de selección y carga de archivo
              const Text(
                'Subir Archivo al Servidor',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : _selectFile,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Seleccionar Archivo Real'),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _selectedFileName ?? 'Ningún archivo seleccionado',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedFileName != null
                                ? Colors.blue.shade900
                                : Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isUploading) ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        const Text(
                          'Subiendo archivo a la VPS...',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ] else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _selectedFileName == null
                                ? null
                                : _uploadFile,
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Subir Archivo'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (_previewPath != null) ...[
                const Text(
                  'Vista Previa del Archivo Descargado:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 3,
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        if (_previewType == 'image') ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_previewPath!),
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ] else if (_previewType == 'video') ...[
                          const Icon(
                            Icons.video_library,
                            size: 64,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '¡Video Descargado con Éxito!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          'Guardado localmente en:\n$_previewPath',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _previewPath = null;
                              _previewType = null;
                            });
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text(
                            'Cerrar Vista Previa',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Listado de archivos en el bucket
              const Text(
                'Archivos en el Servidor (S3 Bucket):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (_isLoadingFiles)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_serverFiles.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'El bucket está vacío o no se pudieron cargar archivos.\nUsa el botón de arriba para subir uno.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _serverFiles.length,
                  itemBuilder: (context, index) {
                    final file = _serverFiles[index];
                    final name = file['name'] as String;
                    final size = file['size'] as int;

                    // Formatear tamaño del archivo legible
                    final sizeStr = (size < 1024 * 1024)
                        ? '${(size / 1024).toStringAsFixed(1)} KB'
                        : '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';

                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.insert_drive_file,
                          color: Colors.blue,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Tamaño: $sizeStr'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.download,
                                color: Colors.blue,
                              ),
                              onPressed: () => _downloadFile(name),
                              tooltip: 'Descargar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteFile(name),
                              tooltip: 'Eliminar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}
