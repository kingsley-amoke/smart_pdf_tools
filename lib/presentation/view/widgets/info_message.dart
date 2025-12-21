import 'package:flutter/material.dart';

SnackBar infoMessageSnackBar(String message) {
  return SnackBar(
    content: Row(
      children: [
        const Icon(Icons.info_outline, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
      ],
    ),
    backgroundColor: const Color(0xFF2563EB), // primary blue
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}
