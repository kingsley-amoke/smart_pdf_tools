import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/core/configs/themes.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/navbar.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class PdfSmartTools extends StatelessWidget {
  const PdfSmartTools({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentProvider>(
      builder: (context, state, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart PDF Toolkit',
          themeMode: state.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: Navbar(),
        );
      },
    );
  }
}
