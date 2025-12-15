import 'dart:io';
import 'package:smart_pdf_tools/domain/models/compression_quality.dart';
import 'package:smart_pdf_tools/domain/models/split_method.dart';

abstract class DocumentRepository {
  Future<Map<String, dynamic>> uploadSingleFile(
    File file, {
    Function(double)? onProgress,
  });
  Future<Map<String, dynamic>> uploadMultipleFiles(
    List<File> files, {
    Function(double)? onProgress,
  });

  Future<String> mergePdfs(
    List<File> files, {
    required Function(double) onProgress,
  });

  Future<String> splitPdf(
    File file, {
    required SplitMethod method,
    String? ranges,
    int? pagesPerSplit,
    required Function(double) onProgress,
  });

  Future<Map<String, dynamic>> compressPdf(
    File file, {
    required CompressionQuality quality,
    bool compressImages = true,
    bool removeMetadata = true,
    required Function(double) onProgress,
  });

  Future<int> getPageCount(File file);
}
