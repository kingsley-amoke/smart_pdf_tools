import 'dart:io';

import 'package:flutter/material.dart';

class PdfCard extends StatelessWidget {
  const PdfCard({
    super.key,
    required this.selectedFiles,
    required this.reorderFiles,
    required this.removeFile,
  });

  final List<File> selectedFiles;
  final void Function(int, int) reorderFiles;
  final void Function(int) removeFile;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: selectedFiles.length,
      onReorder: reorderFiles,
      itemBuilder: (context, index) {
        final file = selectedFiles[index];
        final fileName = file.path.split('/').last;
        final fileSize = (file.lengthSync() / 1024 / 1024).toStringAsFixed(2);

        return Card(
          key: ValueKey(file.path),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  fileSize.contains('MB') &&
                      double.parse(fileSize.split(' ')[0]) > 10
                  ? Colors.orange
                  : Colors.deepPurple,
              foregroundColor: Colors.white,
              child: Text('${index + 1}'),
            ),

            title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('$fileSize MB'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.drag_handle, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => removeFile(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
