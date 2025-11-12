import 'package:path_provider/path_provider.dart';
import 'package:smart_pdf_tools/core/utils/pdf_tools.dart';
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';
import 'package:smart_pdf_tools/domain/repositories/document_repo.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final PdfTools myPdfTools;

  DocumentRepositoryImpl({required this.myPdfTools});

  @override
  Future<List<PdfDocument>> fetchRecent() async {
    // Get temp directory
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;

    final dir = Directory(tempPath);

    if (!dir.existsSync()) {
      return [];
    }

    // List all .pdf files
    final pdfFiles = dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.pdf'))
        .toList();

    // Sort by modified time descending (most recent first)
    pdfFiles.sort(
      (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
    );

    // Convert to PdfDocument models
    final recentDocuments = pdfFiles.map((file) {
      return PdfDocument(
        id: const Uuid().v4(),
        title: file.uri.pathSegments.last,
        sizeBytes: file.lengthSync(),
        createdAt: file.statSync().modified,
        path: file.path,
      );
    }).toList();

    return recentDocuments;
  }

  @override
  Future<File> savePdfToTemp(pw.Document pdf, String fileName) async {
    return myPdfTools.savePdfToTemp(pdf, fileName);
  }

  @override
  Future<PdfDocument> createPdfFromImages(
    List<File> images,
    String filename,
  ) async {
    final file = await myPdfTools.createPdfFromImages(images, filename);

    final savedFile = await savePdfToTemp(file, filename);
    final fileId = Uuid().v4();
    return PdfDocument.fromFile(savedFile, fileId);
  }
}
