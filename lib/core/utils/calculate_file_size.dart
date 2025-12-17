import 'dart:io';

String calculateTotalSize(List<File> selectedFiles) {
  double totalSize = 0.0;
  for (var file in selectedFiles) {
    totalSize += file.lengthSync() / 1024 / 1024;
  }
  return totalSize.toStringAsFixed(2);
}
