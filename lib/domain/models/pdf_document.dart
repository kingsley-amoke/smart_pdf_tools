import 'dart:io';

import 'package:smart_pdf_tools/domain/models/document_type.dart';

class PdfDocument {
  final String id;
  final String title;
  final int sizeBytes;
  final DateTime createdAt;
  final String path;
  final DocumentType type;

  PdfDocument({
    required this.id,
    required this.title,
    required this.sizeBytes,
    required this.createdAt,
    required this.path,
    required this.type,
  });

  factory PdfDocument.fromFile({
    required File file,
    required String fileId,
    required DocumentType type,
  }) {
    return PdfDocument(
      id: fileId,
      title: file.uri.pathSegments.last,
      sizeBytes: file.lengthSync(),
      createdAt: file.statSync().changed,
      path: file.path,
      type: type,
    );
  }
}
