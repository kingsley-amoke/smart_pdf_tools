import 'package:flutter/material.dart';
import 'package:smart_pdf_tools/domain/models/image_format.dart';

class ImageFormatCard extends StatelessWidget {
  const ImageFormatCard({
    super.key,
    required this.format,
    required this.selectedFormat,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final ImageFormat format;
  final ImageFormat selectedFormat;
  final String title;
  final String subtitle;
  final IconData icon;
  final void Function(ImageFormat)? onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedFormat == format;
    return InkWell(
      onTap: () => onTap?.call(format),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue.shade900 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
