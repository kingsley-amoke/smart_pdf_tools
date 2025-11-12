import 'package:flutter/material.dart';

class ToolsScreen extends StatelessWidget {
  final tools = const [
    {'icon': Icons.picture_as_pdf, 'label': 'Image → PDF'},
    {'icon': Icons.image, 'label': 'PDF → Images'},
    {'icon': Icons.merge_type, 'label': 'Merge PDFs'},
    {'icon': Icons.call_split, 'label': 'Split PDF'},
    {'icon': Icons.compress, 'label': 'Compress PDF'},
    {'icon': Icons.edit, 'label': 'Add Signature'},
    {'icon': Icons.text_fields, 'label': 'OCR / Extract Text'},
    {'icon': Icons.share, 'label': 'Share'},
  ];

  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6),
          Text(
            'Tools',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: tools
                  .map(
                    (t) => _ToolCard(
                      icon: t['icon'] as IconData,
                      label: t['label'] as String,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ToolCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$label tapped'))),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary.withOpacity(0.12), Colors.transparent],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primary),
            ),
            SizedBox(height: 10),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(
              'Fast • Sharp • Secure',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
