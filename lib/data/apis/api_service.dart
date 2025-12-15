import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_pdf_tools/core/adapters/split_method_adapter.dart';
import 'package:smart_pdf_tools/core/constants/external_links.dart';
import 'package:smart_pdf_tools/domain/models/compression_quality.dart';
import 'package:smart_pdf_tools/domain/models/image_format.dart';
import 'package:smart_pdf_tools/domain/models/split_method.dart';
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

  /// Split PDF with various methods
  Future<String> splitPdf(
    File file, {
    required SplitMethod method,
    String? ranges,
    int? pagesPerSplit,
    required Function(double) onProgress,
  }) async {
    final splitMethodAdapter = SplitMethodAdapter(method: method);
    try {
      print('📤 Starting split upload...');

      // Prepare form data
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'method': splitMethodAdapter.toApiString(),
        if (ranges != null) 'ranges': ranges,
        if (pagesPerSplit != null) 'pagesPerSplit': pagesPerSplit,
      });

      // Get save directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = '${directory.path}/split_$timestamp.zip';

      print('💾 Will save to: $savePath');

      // Upload and download
      await _dio
          .post(
            '/pdf/split',
            data: formData,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ),
            onSendProgress: (sent, total) {
              final progress = sent / total * 0.5;
              onProgress(progress);
              print('⬆️  Upload: ${(progress * 100).toInt()}%');
            },
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = 0.5 + (received / total * 0.5);
                onProgress(progress);
                print('⬇️  Download: ${(progress * 100).toInt()}%');
              }
            },
          )
          .then((response) async {
            if (response.statusCode == 200 || response.statusCode == 201) {
              // Save ZIP file
              final file = File(savePath);
              await file.writeAsBytes(response.data);
              print('✅ ZIP saved successfully');
            } else {
              throw Exception('Server returned status: ${response.statusCode}');
            }
          });

      return savePath;
    } on DioException catch (e) {
      print('❌ Dio error: ${e.message}');
      throw Exception('Failed to split PDF: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to split PDF: $e');
    }
  }

  /// Get page count from PDF (mock - you'll need backend endpoint for this)
  Future<int> getPageCount(File file) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await _dio.post('/pdf/page-count', data: formData);

      return response.data['pageCount'] as int;
    } catch (e) {
      print('Failed to get page count: $e');
      // Return null or estimate
      return 0;
    }
  }

  Future<Map<String, dynamic>> compressPdf(
    File file, {
    required CompressionQuality quality,
    bool compressImages = true,
    bool removeMetadata = true,
    required Function(double) onProgress,
  }) async {
    try {
      print('📤 Starting compress upload...');

      // Prepare form data
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'quality': quality.name,
        'compressImages': compressImages,
        'removeMetadata': removeMetadata,
      });

      // Get save directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = '${directory.path}/compressed_$timestamp.pdf';

      print('💾 Will save to: $savePath');

      int? compressedSize;
      String? reductionPercentage;

      // Upload and download
      await _dio
          .post(
            '/pdf/compress',
            data: formData,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ),
            onSendProgress: (sent, total) {
              final progress = sent / total * 0.5;
              onProgress(progress);
              print('⬆️  Upload: ${(progress * 100).toInt()}%');
            },
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = 0.5 + (received / total * 0.5);
                onProgress(progress);
                print('⬇️  Download: ${(progress * 100).toInt()}%');
              }
            },
          )
          .then((response) async {
            if (response.statusCode == 200 || response.statusCode == 201) {
              // Get compression stats from headers
              compressedSize = int.tryParse(
                response.headers.value('x-compressed-size') ?? '0',
              );
              reductionPercentage = response.headers.value(
                'x-reduction-percentage',
              );

              // Save file
              final resultFile = File(savePath);
              await resultFile.writeAsBytes(response.data);
              print('✅ File saved successfully');
            } else {
              throw Exception('Server returned status: ${response.statusCode}');
            }
          });

      return {
        'filePath': savePath,
        'compressedSize': compressedSize,
        'reductionPercentage': reductionPercentage,
      };
    } on DioException catch (e) {
      print('❌ Dio error: ${e.message}');
      throw Exception('Failed to compress PDF: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to compress PDF: $e');
    }
  }

  Future<String> convertPdfToImages(
    File file, {
    required ImageFormat format,
    int quality = 90,
    required Function(double) onProgress,
  }) async {
    try {
      print('📤 Starting PDF to images conversion...');

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'format': format.name,
        'quality': quality,
      });

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = '${directory.path}/pdf_images_$timestamp.zip';

      print('💾 Will save to: $savePath');

      await _dio
          .post(
            '/pdf/convert/to-images',
            data: formData,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ),
            onSendProgress: (sent, total) {
              final progress = sent / total * 0.5;
              onProgress(progress);
              print('⬆️  Upload: ${(progress * 100).toInt()}%');
            },
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = 0.5 + (received / total * 0.5);
                onProgress(progress);
                print('⬇️  Download: ${(progress * 100).toInt()}%');
              }
            },
          )
          .then((response) async {
            if (response.statusCode == 200 || response.statusCode == 201) {
              final file = File(savePath);
              await file.writeAsBytes(response.data);
              print('✅ ZIP saved successfully');
            } else {
              throw Exception('Server returned status: ${response.statusCode}');
            }
          });

      return savePath;
    } catch (e) {
      print('❌ Conversion error: $e');
      throw Exception('Failed to convert PDF to images: $e');
    }
  }

  /// Convert images to PDF
  Future<String> convertImagesToPdf(
    List<File> files, {
    required Function(double) onProgress,
  }) async {
    try {
      print('📤 Starting images to PDF conversion...');

      List<MultipartFile> filesList = [];
      for (var file in files) {
        filesList.add(
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        );
      }

      FormData formData = FormData.fromMap({'files': filesList});

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = '${directory.path}/from_images_$timestamp.pdf';

      print('💾 Will save to: $savePath');

      await _dio
          .post(
            '/pdf/convert/images-to-pdf',
            data: formData,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ),
            onSendProgress: (sent, total) {
              final progress = sent / total * 0.5;
              onProgress(progress);
              print('⬆️  Upload: ${(progress * 100).toInt()}%');
            },
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = 0.5 + (received / total * 0.5);
                onProgress(progress);
                print('⬇️  Download: ${(progress * 100).toInt()}%');
              }
            },
          )
          .then((response) async {
            if (response.statusCode == 200 || response.statusCode == 201) {
              final file = File(savePath);
              await file.writeAsBytes(response.data);
              print('✅ PDF saved successfully');
            } else {
              throw Exception('Server returned status: ${response.statusCode}');
            }
          });

      return savePath;
    } catch (e) {
      print('❌ Conversion error: $e');
      throw Exception('Failed to convert images to PDF: $e');
    }
  }
}
