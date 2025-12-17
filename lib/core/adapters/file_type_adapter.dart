import 'package:smart_pdf_tools/domain/models/document_type.dart';

class FileTypeAdapter {
  final DocumentType type;

  const FileTypeAdapter({required this.type});

  String toApiString() {
    switch (type) {
      case DocumentType.pdf:
        return 'pdf';
      case DocumentType.doc:
        return 'doc';
      case DocumentType.image:
        return 'jpg';
      case DocumentType.zip:
        return 'zip';
    }
  }

  DocumentType toDocument(String extension) {
    switch (extension) {
      case '.pdf':
        return DocumentType.pdf;
      case '.zip':
        return DocumentType.zip;
      case '.jpg':
        return DocumentType.image;
      case '.png':
        return DocumentType.image;
      case '.doc':
        return DocumentType.doc;
      case '.docx':
        return DocumentType.doc;

      default:
        return DocumentType.pdf;
    }
  }
}
