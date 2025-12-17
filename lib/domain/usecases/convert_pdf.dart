import 'dart:io';

import 'package:smart_pdf_tools/domain/models/image_format.dart';

abstract class ConvertPdf {
  Future<String> pdfToDoc({
    required File file,
    required Function(double) onProgress,
  });
  Future<String> pdfToImages({
    required File file,
    required ImageFormat format,
    int quality = 90,
    required Function(double) onProgress,
  });
  Future<String> imagesToPdf({
    required List<File> files,
    required Function(double) onProgress,
  });
  Future<String> docToPdf({
    required File file,
    required Function(double) onProgress,
  });
}
