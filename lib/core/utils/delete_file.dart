import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/error_message.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/success_message.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/warning_message.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

Future<void> deleteSpecificFile(
  BuildContext context,
  PdfDocument document,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final provider = context.read<DocumentProvider>();
  try {
    final file = File(document.path);

    if (await file.exists()) {
      await file.delete();
      provider.removeDocumentFromList(document);
      messenger.showSnackBar(
        successMessageSnackBar('File deleted successfully'),
      );
    } else {
      messenger.showSnackBar(warningMessageSnackBar('File not found'));
    }
  } catch (e) {
    messenger.showSnackBar(errorMessageSnackBar('Unable to delete file'));
  }
}
