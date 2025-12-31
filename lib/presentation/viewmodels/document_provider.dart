import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_pdf_tools/core/utils/create_app_folder.dart';
import 'package:smart_pdf_tools/core/utils/get_files_from_path.dart';

import 'package:smart_pdf_tools/data/repositories/document_repo_impl.dart';
import 'package:smart_pdf_tools/domain/models/compression_quality.dart';
import 'package:smart_pdf_tools/domain/models/connection_state.dart';
import 'package:smart_pdf_tools/domain/models/document_type.dart';
import 'package:smart_pdf_tools/domain/models/image_format.dart';
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';
import 'package:smart_pdf_tools/domain/models/split_method.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentRepositoryImpl repo;
  bool loading = false;
  bool isConnected = false;
  ApiConnectionState connectionState = ApiConnectionState.info;
  String connectionMessage = 'Connecting to server...';
  ThemeMode themeMode = ThemeMode.light;

  List<PdfDocument> documents = [];

  DocumentProvider({required this.repo});

  bool toggleTheme(bool isDark) {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    return isDark;
  }

  void onStatusUpdate(String message) {
    connectionMessage = message;
    switch (message) {
      case 'Connecting to server...':
        connectionState = ApiConnectionState.info;
      case 'Connected successfully!':
        connectionState = ApiConnectionState.success;
      case 'Connection failed':
        connectionState = ApiConnectionState.error;
    }
    notifyListeners();
  }

  Future<bool> checkConnection() async {
    final connected = await repo.testConnection(onStatusUpdate);

    isConnected = connected;
    notifyListeners();
    return connected;
  }

  Future<void> loadDocuments() async {
    final directory = await createAppFolder();

    final List<PdfDocument> files = await getFilesFromPath(directory);
    documents.addAll(files);
    notifyListeners();
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

  Future<PdfDocument> mergePdfs(
    List<File> files, {
    required Function(double) onProgress,
  }) async {
    loading = true;
    final res = await repo.mergePdfs(files, onProgress: onProgress);

    final file = File(res);

    final doc = PdfDocument.fromFile(
      file: file,
      fileId: file.path,
      type: DocumentType.pdf,
    );

    addDocumentToList(doc);

    return doc;
  }

  Future<PdfDocument> splitPdf(
    File file, {
    required SplitMethod method,
    String? ranges,
    int? pagesPerSplit,
    required Function(double) onProgress,
  }) async {
    final res = await repo.splitPdf(
      file,
      ranges: ranges,
      pagesPerSplit: pagesPerSplit,
      method: method,
      onProgress: onProgress,
    );

    PdfDocument doc = PdfDocument.fromFile(
      file: File(res),
      fileId: file.path.toString(),
      type: DocumentType.zip,
    );

    addDocumentToList(doc);
    return doc;
  }

  Future<Map<String, dynamic>> compressPdf(
    File file, {
    required CompressionQuality quality,
    bool compressImages = true,
    bool removeMetadata = true,
    required Function(double) onProgress,
  }) async {
    final res = await repo.compressPdf(
      file,
      quality: quality,
      compressImages: compressImages,
      removeMetadata: removeMetadata,
      onProgress: onProgress,
    );

    PdfDocument doc = PdfDocument.fromFile(
      file: File(res['filePath']),
      fileId: file.path.toString(),
      type: DocumentType.pdf,
    );

    addDocumentToList(doc);
    res['doc'] = doc;

    return res;
  }

  Future<PdfDocument> convertImagesToPdf(
    List<File> files, {
    required Function(double) onProgress,
  }) async {
    final res = await repo.convertImagesToPdf(files, onProgress: onProgress);

    final doc = PdfDocument.fromFile(
      file: File(res),
      fileId: res,
      type: DocumentType.pdf,
    );
    addDocumentToList(doc);
    return doc;
  }

  Future<PdfDocument> convertPdfToImages(
    File file, {
    required ImageFormat format,
    int quality = 90,
    required Function(double) onProgress,
  }) async {
    final res = await repo.convertPdfToImages(
      file,
      format: format,
      quality: quality,
      onProgress: onProgress,
    );

    final doc = PdfDocument.fromFile(
      file: File(res),
      fileId: res,
      type: DocumentType.zip,
    );

    addDocumentToList(doc);

    return doc;
  }

  Future<PdfDocument> convertDocxToPdf(
    File file, {
    required Function(double) onProgress,
  }) async {
    final res = await repo.convertDocxToPdf(file, onProgress: onProgress);
    final doc = PdfDocument.fromFile(
      file: File(res),
      fileId: res,
      type: DocumentType.pdf,
    );
    addDocumentToList(doc);
    return doc;
  }

  Future<PdfDocument> convertPdfToDocx(
    File file, {
    required Function(double) onProgress,
  }) async {
    final res = await repo.convertPdfToDocx(file, onProgress: onProgress);

    final doc = PdfDocument.fromFile(
      file: File(res),
      fileId: res,
      type: DocumentType.doc,
    );

    addDocumentToList(doc);
    return doc;
  }

  Future<int> getPageCount(File file) async {
    return await repo.getPageCount(file);
  }

  void addDocumentToList(PdfDocument doc) {
    documents.add(doc);
    notifyListeners();
  }

  void removeDocumentFromList(PdfDocument doc) {
    documents.remove(doc);
    notifyListeners();
  }
}
