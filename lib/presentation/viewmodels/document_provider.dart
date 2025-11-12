import 'package:flutter/material.dart';
import 'package:smart_pdf_tools/core/utils/image_picker.dart';
import 'package:smart_pdf_tools/data/repositories/document_repo_impl.dart';
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentRepositoryImpl repo;
  final ImagePickerService picker;
  List<PdfDocument> recent = [];
  bool loading = false;
  ThemeMode themeMode = ThemeMode.system;

  DocumentProvider({required this.repo, required this.picker});

  Future<void> loadRecent() async {
    loading = true;
    notifyListeners();
    recent = await repo.fetchRecent();
    loading = false;
    notifyListeners();
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  Future<void> scanDocument() async {
    loading = true;
    notifyListeners();
    final image = await picker.captureImage();
    if (image != null) {
      final pdf = await repo.createPdfFromImages([
        image,
      ], 'Scan_${DateTime.now().millisecondsSinceEpoch}');
      recent.insert(0, pdf);
    }
    loading = false;
    notifyListeners();
  }

  Future<void> importAndCreatePdf() async {
    loading = true;
    notifyListeners();
    final images = await picker.importImages();
    if (images.isNotEmpty) {
      final pdf = await repo.createPdfFromImages(
        images,
        'Import_${DateTime.now().millisecondsSinceEpoch}',
      );
      recent.insert(0, pdf);
    }
    loading = false;
    notifyListeners();
  }

  Future<void> mergePdfs() async {}

  Future<void> compressPdf() async {}
}
