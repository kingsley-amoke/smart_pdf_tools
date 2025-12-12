import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;
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

  Future<bool> saveToDownloads(File pdfFile) async {
    try {
      if (!pdfFile.existsSync()) return false;

      // Extract filename
      final fileName = p.basename(pdfFile.path);

      late Directory downloadsDir;

      // PLATFORM-SPECIFIC DOWNLOADS DIRECTORY
      if (Platform.isAndroid) {
        // On Android, Downloads is here
        downloadsDir = Directory('/storage/emulated/0/Download');

        if (!downloadsDir.existsSync()) {
          downloadsDir.createSync(recursive: true);
        }
      } else if (Platform.isIOS) {
        // iOS does not allow writing to a public Downloads dir.
        // We save to app documents folder instead.
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        // Windows, macOS, Linux — standard downloads folder
        downloadsDir =
            await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      // Build final path
      final newPath = p.join(downloadsDir.path, fileName);

      // Copy file
      await pdfFile.copy(newPath);

      return true;
    } catch (e) {
      print("saveToDownloads ERROR: $e");
      return false;
    }
  }
}
