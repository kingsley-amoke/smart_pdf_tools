import 'package:dio/dio.dart';
import 'package:smart_pdf_tools/core/constants/external_links.dart';
import 'dart:io';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ExternalLinks.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Test connection to backend
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get('/pdf');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection failed: $e');
      return false;
    }
  }

  // Upload single PDF file
  Future<Map<String, dynamic>> uploadSingleFile(
    File file, {
    Function(double)? onProgress,
  }) async {
    try {
      String fileName = file.path.split('/').last;

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        '/pdf/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            onProgress(sent / total);
          }
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception('Upload failed: ${e.message}');
    }
  }

  // Upload multiple PDF files
  Future<Map<String, dynamic>> uploadMultipleFiles(
    List<File> files, {
    Function(double)? onProgress,
  }) async {
    try {
      List<MultipartFile> filesList = [];

      for (var file in files) {
        String fileName = file.path.split('/').last;
        filesList.add(
          await MultipartFile.fromFile(file.path, filename: fileName),
        );
      }

      FormData formData = FormData.fromMap({'files': filesList});

      final response = await _dio.post(
        '/pdf/upload-multiple',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            onProgress(sent / total);
          }
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception('Upload failed: ${e.message}');
    }
  }
}
