import 'dart:io';

import 'package:flutter/material.dart';

import 'package:smart_pdf_tools/data/repositories/document_repo_impl.dart';

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
}
