import 'package:path/path.dart' as p;

Future<String> getFileExtension(String filePath) async {
  return p.extension(filePath);
}
