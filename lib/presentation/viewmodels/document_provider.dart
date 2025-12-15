import 'dart:io';

import 'package:flutter/material.dart';

import 'package:smart_pdf_tools/data/repositories/document_repo_impl.dart';
import 'package:smart_pdf_tools/domain/models/compression_quality.dart';
import 'package:smart_pdf_tools/domain/models/image_format.dart';
import 'package:smart_pdf_tools/domain/models/split_method.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentRepositoryImpl repo;
  bool loading = false;

  bool isConnected = false;
  ThemeMode themeMode = ThemeMode.system;

  DocumentProvider({required this.repo});

  Future<bool> checkConnection() async {
    final connected = await repo.testConnection();

    isConnected = connected;
    notifyListeners();
    return connected;
  }

  Future<Map<String, dynamic>> uploadSingleFile(
    File file, {
    dynamic Function(double)? onProgress,
  }) async {
    loading = true;
    notifyListeners();

    return await repo.uploadSingleFile(file, onProgress: onProgress);
  }

  Future<Map<String, dynamic>> uploadMultipleFiles(
    List<File> files, {
    dynamic Function(double)? onProgress,
  }) async {
    loading = true;
    notifyListeners();

    return await repo.uploadMultipleFiles(files, onProgress: onProgress);
  }

  Future<String> mergePdfs(
    List<File> files, {
    required Function(double) onProgress,
  }) async {
    loading = true;
    notifyListeners();

    return await repo.mergePdfs(files, onProgress: onProgress);
  }

  Future<String> splitPdf(
    File file, {
    required SplitMethod method,
    String? ranges,
    int? pagesPerSplit,
    required Function(double) onProgress,
  }) async {
    return await repo.splitPdf(
      file,
      ranges: ranges,
      pagesPerSplit: pagesPerSplit,
      method: method,
      onProgress: onProgress,
    );
  }

  Future<Map<String, dynamic>> compressPdf(
    File file, {
    required CompressionQuality quality,
    bool compressImages = true,
    bool removeMetadata = true,
    required Function(double) onProgress,
  }) async {
    return await repo.compressPdf(
      file,
      quality: quality,
      compressImages: compressImages,
      removeMetadata: removeMetadata,
      onProgress: onProgress,
    );
  }

  Future<String> convertImagesToPdf(
    List<File> files, {
    required Function(double) onProgress,
  }) async {
    return await repo.convertImagesToPdf(files, onProgress: onProgress);
  }

  Future<String> convertPdfToImages(
    File file, {
    required ImageFormat format,
    int quality = 90,
    required Function(double) onProgress,
  }) async {
    return await repo.convertPdfToImages(
      file,
      format: format,
      quality: quality,
      onProgress: onProgress,
    );
  }

  Future<int> getPageCount(File file) async {
    return await repo.getPageCount(file);
  }
}
