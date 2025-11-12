import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:smart_pdf_tools/core/utils/pdf_tools.dart';

class PdfViewerScreen extends StatelessWidget {
  final File pdfFile;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfFile,
    required this.title,
  });

  Future<void> _sharePdf(BuildContext context) async {
    if (!pdfFile.existsSync()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File not found')));
      return;
    }

    await PdfTools().sharePdf(pdfFile);
  }

  @override
  Widget build(BuildContext context) {
    final controller = PdfController(
      document: PdfDocument.openFile(pdfFile.path),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () async => _sharePdf(context),
            tooltip: 'Download / Share',
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: PdfView(
        controller: controller,
        scrollDirection: Axis.vertical,
        pageSnapping: true,
        // renderer: PdfViewRenderer.defaultRenderer,
      ),
    );
  }
}
