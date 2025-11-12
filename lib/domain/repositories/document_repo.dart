import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';

abstract class DocumentRepository {
  Future<List<PdfDocument>> fetchRecent();
  Future<PdfDocument> createPdfFromImages(List<File> images, String filename);
  Future<File> savePdfToTemp(pw.Document pdf, String fileName);
}
