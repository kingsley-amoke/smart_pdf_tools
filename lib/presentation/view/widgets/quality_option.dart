import 'package:flutter/material.dart';
import 'package:smart_pdf_tools/domain/models/compression_quality.dart';

class QualityOption extends StatelessWidget {
  const QualityOption({
    super.key,
    required this.quality,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.onChanged,
    required this.selectedQuality,
  });

  final CompressionQuality quality;
  final CompressionQuality selectedQuality;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final void Function() onTap;
  final void Function(CompressionQuality value) onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<CompressionQuality>(
              groupValue: selectedQuality,
              onChanged: (value) => onChanged,
              value: quality,
              activeColor: color,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
