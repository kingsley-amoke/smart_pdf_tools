import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/core/utils/image_picker.dart';
import 'package:smart_pdf_tools/core/utils/pdf_tools.dart';
import 'package:smart_pdf_tools/data/repositories/document_repo_impl.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';
import 'package:smart_pdf_tools/smartpdftoolkit.dart';

void main() {
  final ImagePickerService picker = ImagePickerService();
  final PdfTools pdfTools = PdfTools();

  final repo = DocumentRepositoryImpl(myPdfTools: pdfTools);

  runApp(
    ChangeNotifierProvider(
      create: (_) => DocumentProvider(repo: repo, picker: picker),
      child: SmartPdfToolkit(),
    ),
  );
}
