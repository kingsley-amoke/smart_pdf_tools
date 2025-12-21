import 'package:flutter/material.dart';

SnackBar warningMessageSnackBar(String message) {
  return SnackBar(
    content: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
      ],
    ),
    backgroundColor: const Color(0xFFF59E0B), // amber warning
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}
