import 'package:flutter/material.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/connection_status.dart';

AppBar myAppbar(
  BuildContext context, {
  required String title,
  bool showBackIcon = true,
  bool centerTitle = false,
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    elevation: 0,
    backgroundColor: Theme.of(context).colorScheme.surface,
    foregroundColor: Theme.of(context).colorScheme.onSurface,
    centerTitle: centerTitle,
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        fontSize: 20,
      ),
    ),
    leading: showBackIcon
        ? IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.chevron_left),
          )
        : null,
    actions: [ConnectionStatus()],
  );
}
