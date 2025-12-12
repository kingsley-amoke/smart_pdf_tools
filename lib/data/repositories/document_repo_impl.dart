import 'package:smart_pdf_tools/data/apis/api_service.dart';
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

  Future<bool> testConnection() async {
    final connected = await apiService.testConnection();
    return connected;
  }
}
