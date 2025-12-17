import 'package:flutter/material.dart';
import 'package:smart_pdf_tools/presentation/view/pages/convert_to_docx.dart';
import 'package:smart_pdf_tools/presentation/view/pages/convert_to_images.dart';
import 'package:smart_pdf_tools/presentation/view/pages/doc_to_pdf.dart';
import 'package:smart_pdf_tools/presentation/view/pages/image_to_pdf.dart';

class ConvertOptions extends StatelessWidget {
  const ConvertOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Choose Conversion',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.image, color: Colors.blue.shade700),
            ),
            title: const Text('PDF to Images'),
            subtitle: const Text('Convert PDF pages to PNG/JPG'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConvertToImagesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Images to PDF
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.picture_as_pdf, color: Colors.purple.shade700),
            ),
            title: const Text('Images to PDF'),
            subtitle: const Text('Create PDF from multiple images'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImagesToPdfScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // PDF to DOCX
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.description, color: Colors.indigo.shade700),
            ),
            title: const Text('PDF to DOCX'),
            subtitle: const Text('Convert PDF to editable Word document'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PdfToDocxScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // DOCX to PDF
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.picture_as_pdf, color: Colors.green.shade700),
            ),
            title: const Text('DOCX to PDF'),
            subtitle: const Text('Convert Word document to PDF'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DocxToPdfScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
