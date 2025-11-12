import 'dart:io';

class PdfDocument {
  final String id;
  final String title;
  final int sizeBytes;
  final DateTime createdAt;
  final String path; // new field

  PdfDocument({
    required this.id,
    required this.title,
    required this.sizeBytes,
    required this.createdAt,
    required this.path,
  });

  factory PdfDocument.fromFile(File file, String fileId) {
    return PdfDocument(
      id: fileId,
      title: file.uri.pathSegments.last,
      sizeBytes: file.lengthSync(),
      createdAt: file.statSync().changed,
      path: file.path,
    );
  }
}
