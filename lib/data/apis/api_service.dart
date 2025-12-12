import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<String> mergePdfs(
    List<File> files, {
    required Function(double) onProgress,
  }) async {
    try {
      print('📤 Starting merge upload...');

      // Prepare form data with multiple files
      List<MultipartFile> filesList = [];
      for (var file in files) {
        String fileName = file.path.split('/').last;
        filesList.add(
          await MultipartFile.fromFile(file.path, filename: fileName),
        );
      }

      FormData formData = FormData.fromMap({'files': filesList});

      // Get save directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = '${directory.path}/merged_$timestamp.pdf';

      print('💾 Will save to: $savePath');

      // Upload and download
      await _dio
          .post(
            '/pdf/merge',
            data: formData,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ),
            onSendProgress: (sent, total) {
              // Upload progress (0 to 0.5)
              final progress = sent / total * 0.5;
              onProgress(progress);
              print('⬆️  Upload: ${(progress * 100).toInt()}%');
            },
            onReceiveProgress: (received, total) {
              if (total != -1) {
                // Download progress (0.5 to 1.0)
                final progress = 0.5 + (received / total * 0.5);
                onProgress(progress);
                print('⬇️  Download: ${(progress * 100).toInt()}%');
              }
            },
          )
          .then((response) async {
            if (response.statusCode == 200 || response.statusCode == 201) {
              // Save file to phone
              final file = File(savePath);
              await file.writeAsBytes(response.data);
              print('✅ File saved successfully');
            } else {
              throw Exception('Server returned status: ${response.statusCode}');
            }
          });

      return savePath;
    } on DioException catch (e) {
      print('❌ Dio error: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
      }
      throw Exception('Failed to merge PDFs: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to merge PDFs: $e');
    }
  }
}
