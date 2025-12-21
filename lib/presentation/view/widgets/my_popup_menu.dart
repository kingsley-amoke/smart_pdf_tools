import 'package:flutter/material.dart';
import 'package:smart_pdf_tools/core/utils/delete_file.dart';
import 'package:smart_pdf_tools/core/utils/save_file.dart';
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';
import 'package:smart_pdf_tools/domain/models/popup_options.dart';

class MyPopupMenuButton extends StatelessWidget {
  const MyPopupMenuButton({super.key, required this.document});

  final PdfDocument document;

  void _onMenuItemSelected(BuildContext context, PopupOptions value) {
    switch (value) {
      case PopupOptions.view:
        // Action for Option 1
        break;

      case PopupOptions.download:
        saveLocalFileToDownloads(context, document);

      case PopupOptions.delete:
        deleteSpecificFile(context, document);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PopupOptions>(
      onSelected: (value) {
        _onMenuItemSelected(context, value);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<PopupOptions>>[
        // const PopupMenuItem<PopupOptions>(
        //   value: PopupOptions.view,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text('View', style: TextStyle(fontSize: 16, color: Colors.blue)),
        //       Icon(Icons.visibility, color: Colors.blue),
        //     ],
        //   ),
        // ),
        const PopupMenuItem<PopupOptions>(
          value: PopupOptions.download,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Download',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
              Icon(Icons.download, color: Colors.green),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<PopupOptions>(
          value: PopupOptions.delete,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delete', style: TextStyle(fontSize: 16, color: Colors.red)),
              Icon(Icons.delete, color: Colors.red),
            ],
          ),
        ),
      ],
    );
  }
}
