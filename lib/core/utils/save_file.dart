import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/error_message.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/success_message.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/warning_message.dart';

Future<void> saveLocalFileToDownloads(
  BuildContext context,
  PdfDocument document,
) async {
  final messenger = ScaffoldMessenger.of(context);

  if (Platform.isAndroid) {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  try {
    final File localFile = File(document.path);

    if (!await localFile.exists()) {
      messenger.showSnackBar(warningMessageSnackBar('File not found'));
      return;
    }

    final SaveFileDialogParams params = SaveFileDialogParams(
      sourceFilePath: document.path,
      fileName: document.title,
    );

    final String? resultPath = await FlutterFileDialog.saveFile(params: params);

    if (resultPath != null) {
      messenger.showSnackBar(successMessageSnackBar('File Saved!'));
    } else {
      messenger.showSnackBar(warningMessageSnackBar('Saving Cancelled'));
    }
  } catch (e) {
    messenger.showSnackBar(errorMessageSnackBar('Unable to Save file'));
  }
}
