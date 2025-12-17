import 'package:flutter/material.dart';

class EmptySelection extends StatelessWidget {
  const EmptySelection({super.key, required this.icon, required this.type});

  final IconData icon;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No $type selected',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add ${type}s',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
