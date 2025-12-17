import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:smart_pdf_tools/core/constants/variables.dart';

Future<String> createAppFolder() async {
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  // Append the new folder name to the path
  final Directory appDocDirFolder = Directory('${appDocDir.path}/$appFolder');

  // Check if the folder already exists
  if (await appDocDirFolder.exists()) {
    return appDocDirFolder.path;
  } else {
    // If not, create the folder recursively
    final Directory appDocDirNewFolder = await appDocDirFolder.create(
      recursive: true,
    );
    return appDocDirNewFolder.path;
  }
}
