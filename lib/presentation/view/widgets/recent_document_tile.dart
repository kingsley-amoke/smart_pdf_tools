import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_pdf_tools/core/utils/date_format.dart';
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';
import 'package:smart_pdf_tools/presentation/view/pages/pdf_viewer.dart';

class RecentDocumentTile extends StatelessWidget {
  const RecentDocumentTile({super.key, required this.document});

  final PdfDocument document;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.picture_as_pdf,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(document.title, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${(document.sizeBytes / 1024).toStringAsFixed(0)} KB • ${relativeDate(document.createdAt)}',
      ),
      trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
      onTap: () {
        final file = File(document.path);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PdfViewerScreen(pdfFile: file, title: document.title),
          ),
        );
      },
    );
  }
}
