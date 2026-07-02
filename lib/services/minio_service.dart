import 'dart:async';
import 'dart:io';
import 'package:minio/minio.dart';
import 'package:minio/io.dart';

class MinioService {
  static final MinioService instance = MinioService._init();

  MinioService._init();

  Minio? _minio;
  String _bucketName = 'pruebas';

  bool get isInitialized => _minio != null;

  // Inicialización dinámica del cliente MinIO
  void initialize({
    required String endPoint,
    required String accessKey,
    required String secretKey,
    required String bucketName,
  }) {
    _bucketName = bucketName;
    _minio = Minio(
      endPoint: endPoint,
      port: 443,
      useSSL: true,
      accessKey: accessKey,
      secretKey: secretKey,
    );
  }

  // Listar objetos en el bucket
  Future<List<Map<String, dynamic>>> listObjects() async {
    if (_minio == null) throw Exception('MinIO Client no inicializado');

    final List<Map<String, dynamic>> fileList = [];
    try {
      final stream = _minio!.listObjects(_bucketName);
      await for (var chunk in stream) {
        for (var obj in chunk.objects) {
          if (obj.key != null) {
            fileList.add({
              'name': obj.key,
              'size': obj.size,
              'lastModified': obj.lastModified,
            });
          }
        }
      }
    } catch (e) {
      print('Error listing objects: $e');
      rethrow;
    }
    return fileList;
  }

  // Subir un archivo usando fPutObject
  Future<void> uploadFile(String objectName, String filePath) async {
    if (_minio == null) throw Exception('MinIO Client no inicializado');
    try {
      await _minio!.fPutObject(_bucketName, objectName, filePath);
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  // Descargar un archivo usando getObject (flujo de bytes)
  Future<void> downloadFile(String objectName, String localSavePath) async {
    if (_minio == null) throw Exception('MinIO Client no inicializado');
    try {
      // 1. Obtener el flujo de bytes desde MinIO usando getObject (evita bug de fGetObject en archivos > 5MB)
      final Stream<List<int>> stream = await _minio!.getObject(_bucketName, objectName);

      // 2. Eliminar archivo local si ya existe para asegurar una descarga limpia
      final localFile = File(localSavePath);
      if (await localFile.exists()) {
        await localFile.delete();
      }

      // 3. Escribir el flujo de bytes en el archivo local de forma eficiente
      final IOSink sink = localFile.openWrite();
      await sink.addStream(stream);
      await sink.close();
    } catch (e) {
      print('Error downloading file via stream: $e');
      rethrow;
    }
  }

  // Eliminar un archivo usando removeObject
  Future<void> deleteFile(String objectName) async {
    if (_minio == null) throw Exception('MinIO Client no inicializado');
    try {
      await _minio!.removeObject(_bucketName, objectName);
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }
}
