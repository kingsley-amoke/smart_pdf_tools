import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:smart_pdf_tools/presentation/view/pages/compress.dart';
import 'package:smart_pdf_tools/presentation/view/pages/merge.dart';
import 'package:smart_pdf_tools/presentation/view/pages/split.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/convert_options.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/feature_card.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/my_appbar.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/recent_document.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(
        context,
        title: 'PDF Utility Tools',
        showBackIcon: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (context.watch<DocumentProvider>().connectionMessage != null)
              Text(context.watch<DocumentProvider>().connectionMessage!),

            GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              primary: true,
              itemCount: _features.length,
              itemBuilder: (context, index) {
                final feature = _features[index];

                return FeatureCard(
                  title: feature.title,
                  subtitle: feature.subtitle,
                  icon: feature.icon,
                  gradient: feature.gradient,
                  delay: (index * 100).ms,
                  onTap: () => feature.onTap(context),
                );
              },
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 5,
              ),
              child: Text(
                'Recent Documents',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            RecentDocument(),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final void Function(BuildContext) onTap;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
}

final List<_FeatureItem> _features = [
  _FeatureItem(
    title: 'Merge PDFs',
    subtitle: 'Combine multiple files',
    icon: Icons.merge_type,
    gradient: LinearGradient(
      colors: [Colors.deepPurpleAccent, Colors.deepPurple],
    ),
    onTap: (context) => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MergeScreen()),
    ),
  ),
  _FeatureItem(
    title: 'Split PDF',
    subtitle: 'Extract pages',
    icon: Icons.content_cut,
    gradient: LinearGradient(colors: [Colors.tealAccent, Colors.teal]),
    onTap: (context) => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SplitScreen()),
    ),
  ),
  _FeatureItem(
    title: 'Compress',
    subtitle: 'Reduce file size',
    icon: Icons.compress,
    gradient: LinearGradient(colors: [Colors.orangeAccent, Colors.orange]),
    onTap: (context) => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CompressScreen()),
    ),
  ),
  _FeatureItem(
    title: 'Convert',
    subtitle: 'PDF to images & more',
    icon: Icons.transform,
    gradient: LinearGradient(colors: [Colors.lightBlueAccent, Colors.blue]),
    onTap: (context) => showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ConvertOptions(),
    ),
  ),
];
