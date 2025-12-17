import 'package:flutter/material.dart';
import 'package:smart_pdf_tools/core/utils/date_format.dart';
import 'package:smart_pdf_tools/core/utils/format_file_size.dart';
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';

class RecentDocumentTile extends StatelessWidget {
  const RecentDocumentTile({
    super.key,
    required this.document,
    this.icon = Icons.picture_as_pdf,
    required this.onTap,
  });

  final PdfDocument document;
  final IconData? icon;
  final Function() onTap;

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
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(document.title, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${formatFileSize(document.sizeBytes)} • ${relativeDate(document.createdAt)}',
      ),
      trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
      onTap: onTap,
    );
  }
}
