import 'package:archive/archive.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<void> extractZip({required String filePath}) async {
  final file = File(filePath);
  final bytes = file.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);
  final path = await FilePicker.platform.getDirectoryPath() ?? '';
  for (final entry in archive) {
    final fileName = entry.name;
    if (entry.isFile) {
      final fileBytes = entry.readBytes();
      File('$path/$fileName')
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!.toList());
    } else {
      await Directory('$path/$fileName').create(recursive: true);
    }
  }
}
