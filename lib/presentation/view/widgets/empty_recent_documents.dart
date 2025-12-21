import 'package:flutter/material.dart';
import 'package:smart_pdf_tools/presentation/view/pages/image_to_pdf.dart';

class EmptyRecentDocuments extends StatelessWidget {
  const EmptyRecentDocuments({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.insert_drive_file_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No recent documents', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Your processed PDFs will appear here',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // CTA
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => ImagesToPdfScreen()));
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}
