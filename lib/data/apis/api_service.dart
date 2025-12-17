import 'package:dio/dio.dart';
import 'package:smart_pdf_tools/core/constants/external_links.dart';
import 'package:smart_pdf_tools/data/apis/compress_pdf_api.dart';
import 'package:smart_pdf_tools/data/apis/convert_pdf_api.dart';
import 'package:smart_pdf_tools/data/apis/merge_pdf_api.dart';
import 'package:smart_pdf_tools/data/apis/split_pdf_api.dart';
import 'package:smart_pdf_tools/domain/models/compression_quality.dart';
import 'package:smart_pdf_tools/domain/models/image_format.dart';
import 'package:smart_pdf_tools/domain/models/split_method.dart';
import 'dart:io';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ExternalLinks.baseUrl,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    ),
  );

  ConvertPdfApi get convertPdf => ConvertPdfApi(dio: _dio);

  // Test connection to backend
  Future<bool> testConnection(Function(String)? onStatusUpdate) async {
    try {
      onStatusUpdate?.call('Connecting to server...');

      final response = await _dio.get(
        '/pdf',
        options: Options(
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );

      if (response.statusCode == 200) {
        onStatusUpdate?.call('Connected successfully!');
        return true;
      }

      onStatusUpdate?.call('Connection failed');
      return false;
    } catch (e) {
      print('❌ Connection error: $e');
      onStatusUpdate?.call('Connection failed: $e');
      return false;
    }
    // try {
    //   final response = await _dio.get('/pdf');
    //   print((response));
    //   return response.statusCode == 200;
    // } catch (e) {
    //   print(e);
    //   return false;
    // }
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
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception('Upload failed: ${e.message}');
    }
  }

  //MERGE PDF
  Future<String> mergePdfs(
    List<File> files, {
    required Function(double) onProgress,
  }) async {
    final mergePdf = MergePdfApi(
      dio: _dio,
      files: files,
      onProgress: onProgress,
    );
    return mergePdf();
  }

  /// SPLIT PDF
  Future<String> splitPdf(
    File file, {
    required SplitMethod method,
    String? ranges,
    int? pagesPerSplit,
    required Function(double) onProgress,
  }) async {
    final splitPdf = SplitPdfApi(
      dio: _dio,
      file: file,
      method: method,
      onProgress: onProgress,
      pagesPerSplit: pagesPerSplit,
      ranges: ranges,
    );

    return splitPdf();
  }

  //GET PAGE COUNT
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
      // Return null or estimate
      return 0;
    }
  }

  //COMPRESS PDF
  Future<Map<String, dynamic>> compressPdf(
    File file, {
    required CompressionQuality quality,
    bool compressImages = true,
    bool removeMetadata = true,
    required Function(double) onProgress,
  }) async {
    final compressPdf = CompressPdfApi(
      dio: _dio,
      file: file,
      quality: quality,
      onProgress: onProgress,
    );
    return compressPdf();
  }

  //CONVERT PDF TO IMAGES
  Future<String> convertPdfToImages(
    File file, {
    required ImageFormat format,
    int quality = 90,
    required Function(double) onProgress,
  }) async {
    return convertPdf.pdfToImages(
      file: file,
      format: format,
      quality: quality,
      onProgress: onProgress,
    );
  }

  // CONVERT IMAGES TO PDF
  Future<String> convertImagesToPdf(
    List<File> files, {
    required Function(double) onProgress,
  }) async {
    return convertPdf.imagesToPdf(files: files, onProgress: onProgress);
  }

  /// Convert PDF to DOCX
  Future<String> convertPdfToDocx(
    File file, {
    required Function(double) onProgress,
  }) async {
    return convertPdf.pdfToDoc(file: file, onProgress: onProgress);
  }

  /// Convert DOCX to PDF
  Future<String> convertDocxToPdf(
    File file, {
    required Function(double) onProgress,
  }) async {
    return convertDocxToPdf(file, onProgress: onProgress);
  }
}
