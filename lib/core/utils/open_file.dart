// Helper method to open files
import 'package:open_file/open_file.dart';

Future<void> openFile(String filePath) async {
  try {
    await OpenFile.open(filePath);
  } catch (e) {
    print('Failed to open file: $e');
    throw Exception('Could not open file');
  }
}
