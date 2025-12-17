import 'package:flutter/material.dart';
import 'package:smart_pdf_tools/domain/models/split_method.dart';

class MethodSelector extends StatelessWidget {
  const MethodSelector({
    super.key,
    required this.example,
    required this.icon,
    required this.method,
    required this.onTap,
    required this.subtitle,
    required this.title,
    required this.onChanged,
    required this.isSelected,
    required this.selectedMethod,
  });

  final SplitMethod method;
  final IconData icon;
  final String title;
  final String subtitle;
  final String example;
  final void Function() onTap;
  final void Function(SplitMethod?) onChanged;
  final bool isSelected;
  final SplitMethod selectedMethod;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.teal.shade300 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<SplitMethod>(
              value: method,
              groupValue: selectedMethod,
              onChanged: (value) => onChanged(value),
              activeColor: Colors.teal.shade700,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.teal.shade700 : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? Colors.teal.shade900 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    example,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
