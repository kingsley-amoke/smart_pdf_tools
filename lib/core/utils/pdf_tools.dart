import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfTools {
  Future<pw.Document> createPdfFromImages(
    List<File> images,
    String filename,
  ) async {
    final pdf = pw.Document();
    for (var img in images) {
      final image = pw.MemoryImage(img.readAsBytesSync());
      pdf.addPage(
        pw.Page(build: (context) => pw.Center(child: pw.Image(image))),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename.pdf');
    await file.writeAsBytes(await pdf.save());

    return pdf;
  }

  Future<File> savePdfToTemp(pw.Document pdf, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$fileName.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> sharePdf(File pdfFile) async {
    if (!pdfFile.existsSync()) return;

    final params = ShareParams(
      files: [XFile(pdfFile.path)],
      text: 'Here is your PDF: ${pdfFile.uri.pathSegments.last}',
    );

    await SharePlus.instance.share(params);
  }
}
