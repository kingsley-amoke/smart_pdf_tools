import 'dart:io';
import 'package:smart_pdf_tools/core/adapters/file_type_adapter.dart';
import 'package:smart_pdf_tools/core/utils/get_file_extension.dart';
import 'package:smart_pdf_tools/domain/models/document_type.dart';
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';

Future<List<PdfDocument>> getFilesFromPath(String directoryPath) async {
  final Directory directory = Directory(directoryPath);
  final docAdapter = FileTypeAdapter(type: DocumentType.pdf);
  final List<PdfDocument> files = [];
  try {
    List<FileSystemEntity> entities = await directory.list().toList();

    for (var entity in entities) {
      if (entity is File) {
        final type = await getFileExtension(entity.path);

        files.add(
          PdfDocument.fromFile(
            file: entity,
            fileId: entity.path,
            type: docAdapter.toDocument(type),
          ),
        );
      }
    }
  } catch (e) {
    return [];
  }

  return files;
}
