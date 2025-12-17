import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/core/utils/extract_zip.dart';
import 'package:smart_pdf_tools/core/utils/open_file.dart';
import 'package:smart_pdf_tools/domain/models/document_type.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/my_appbar.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/recent_document_tile.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, title: 'History', showBackIcon: false),
      body: Consumer<DocumentProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.documents.length,
            itemBuilder: (context, index) {
              final document = provider.documents.reversed.toList()[index];

              return provider.documents.isNotEmpty
                  ? switch (document.type) {
                      DocumentType.pdf => RecentDocumentTile(
                        document: document,
                        onTap: () => openFile(document.path),
                      ),

                      DocumentType.zip => RecentDocumentTile(
                        document: document,
                        icon: Icons.folder_zip,
                        onTap: () => extractZip(filePath: document.path),
                      ),

                      DocumentType.image => ListTile(),

                      DocumentType.doc => RecentDocumentTile(
                        document: document,
                        icon: Icons.file_copy,
                        onTap: () => openFile(document.path),
                      ),
                    }
                  : Center(child: Text('No files'));
            },
          );
        },
      ),
    );
  }
}
