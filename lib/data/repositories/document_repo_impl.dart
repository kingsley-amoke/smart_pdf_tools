import 'package:smart_pdf_tools/data/apis/api_service.dart';
import 'package:smart_pdf_tools/domain/models/compression_quality.dart';
import 'package:smart_pdf_tools/domain/models/image_format.dart';
import 'package:smart_pdf_tools/domain/models/split_method.dart';
import 'package:smart_pdf_tools/domain/repositories/document_repo.dart';
import 'dart:io';

class DocumentRepositoryImpl implements DocumentRepository {
  final ApiService apiService;
  DocumentRepositoryImpl({required this.apiService});

  @override
  Future<Map<String, dynamic>> uploadMultipleFiles(
    List<File> files, {
    Function(double)? onProgress,
  }) async {
    return await apiService.uploadMultipleFiles(files, onProgress: onProgress);
  }

  @override
  Future<Map<String, dynamic>> uploadSingleFile(
    File file, {
    Function(double)? onProgress,
  }) async {
    return await apiService.uploadSingleFile(file, onProgress: onProgress);
  }

  @override
  Future<String> mergePdfs(
    List<File> files, {
    required Function(double) onProgress,
  }) async {
    return await apiService.mergePdfs(files, onProgress: onProgress);
  }

  @override
  Future<String> splitPdf(
    File file, {
    required SplitMethod method,
    String? ranges,
    int? pagesPerSplit,
    required Function(double) onProgress,
  }) async {
    return apiService.splitPdf(
      file,
      ranges: ranges,
      pagesPerSplit: pagesPerSplit,
      method: method,
      onProgress: onProgress,
    );
  }

  @override
  Future<Map<String, dynamic>> compressPdf(
    File file, {
    required CompressionQuality quality,
    bool compressImages = true,
    bool removeMetadata = true,
    required Function(double) onProgress,
  }) async {
    return apiService.compressPdf(
      file,
      quality: quality,
      compressImages: compressImages,
      removeMetadata: removeMetadata,
      onProgress: onProgress,
    );
  }

  @override
  Future<String> convertImagesToPdf(
    List<File> files, {
    required Function(double) onProgress,
  }) async {
    return apiService.convertImagesToPdf(files, onProgress: onProgress);
  }

  @override
  Future<String> convertPdfToImages(
    File file, {
    required ImageFormat format,
    int quality = 90,
    required Function(double) onProgress,
  }) async {
    return apiService.convertPdfToImages(
      file,
      format: format,
      quality: quality,
      onProgress: onProgress,
    );
  }

  @override
  Future<int> getPageCount(File file) async {
    return apiService.getPageCount(file);
  }

  Future<bool> testConnection() async {
    final connected = await apiService.testConnection();
    return connected;
  }
}
