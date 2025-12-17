import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_pdf_tools/core/utils/calculate_file_size.dart';

class TotalFilesFooter extends StatelessWidget {
  const TotalFilesFooter({super.key, required this.selectedFiles});

  final List<File> selectedFiles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${selectedFiles.length} file(s)',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            'Total: ${calculateTotalSize(selectedFiles)} MB',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
