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

  // Descargar un archivo usando fGetObject
  Future<void> downloadFile(String objectName, String localSavePath) async {
    if (_minio == null) throw Exception('MinIO Client no inicializado');
    try {
      // Eliminar archivo local si ya existe para evitar conflictos de reintento de rango de bytes (416 Range Not Satisfiable)
      final localFile = File(localSavePath);
      if (await localFile.exists()) {
        await localFile.delete();
      }

      await _minio!.fGetObject(_bucketName, objectName, localSavePath);
    } catch (e) {
      print('Error downloading file: $e');
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
