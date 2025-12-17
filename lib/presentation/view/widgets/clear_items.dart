import 'package:flutter/material.dart';

class ClearItems extends StatelessWidget {
  const ClearItems({super.key, required this.onTap});

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.clear_all),
      label: const Text('Clear All'),
    );
  }
}
