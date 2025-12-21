import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/core/utils/extract_zip.dart';
import 'package:smart_pdf_tools/core/utils/open_file.dart';
import 'package:smart_pdf_tools/domain/models/document_type.dart';
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/empty_recent_documents.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/recent_document_tile.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class RecentDocument extends StatelessWidget {
  const RecentDocument({super.key});

  @override
  Widget build(BuildContext context) {
    List<PdfDocument> documents = context.watch<DocumentProvider>().documents;
    return documents.isNotEmpty
        ? ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            primary: true,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              if (documents.isNotEmpty) {
                final PdfDocument document = documents.length > 10
                    ? documents.reversed.toList().sublist(0, 10)[index]
                    : documents.reversed.toList()[index];
                return switch (document.type) {
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

                    onTap: () => openFile(document.path),
                  ),
                };
              } else {
                return Center(child: Text('No files'));
              }
            },
          )
        : EmptyRecentDocuments();
  }
}
