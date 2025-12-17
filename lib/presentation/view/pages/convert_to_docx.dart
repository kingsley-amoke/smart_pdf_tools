import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/core/utils/open_file.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/error_message.dart';
import 'dart:io';

import 'package:smart_pdf_tools/presentation/view/widgets/file_card.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/my_appbar.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/primary_button.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/success_dialog.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class PdfToDocxScreen extends StatefulWidget {
  const PdfToDocxScreen({super.key});

  @override
  State<PdfToDocxScreen> createState() => _PdfToDocxScreenState();
}

class _PdfToDocxScreenState extends State<PdfToDocxScreen>
    with TickerProviderStateMixin {
  File? _selectedFile;
  bool _isProcessing = false;
  double _progress = 0.0;
  String _statusMessage = '';

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();

    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  Future<void> _convertToDocx() async {
    if (_selectedFile == null) {
      _showError('Please select a PDF file');
      return;
    }

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _statusMessage = 'Preparing...';
    });

    try {
      final resultPath = await context
          .read<DocumentProvider>()
          .convertPdfToDocx(
            _selectedFile!,
            onProgress: (progress) {
              setState(() {
                _progress = progress;
                if (progress < 0.5) {
                  _statusMessage = 'Uploading PDF...';
                } else if (progress < 0.9) {
                  _statusMessage = 'Converting to DOCX...';
                } else {
                  _statusMessage = 'Downloading...';
                }
              });
            },
          );

      setState(() {
        _isProcessing = false;
        _statusMessage = 'Success!';
      });

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SuccessDialog(
            filePath: resultPath,
            removeFile: _removeFile,
            title: 'Conversion Complete!',
            description: 'Your PDF has been converted to DOCX',
            removeText: 'Done',
            openFileText: 'Open DOCX',
            onPressed: () => openFile(resultPath),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Failed';
      });

      if (mounted) {
        _showError('Failed to convert: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(errorMessageSnackBar(message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, title: 'PDF to DOCX Converter'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FileCard(
                    selectedFile: _selectedFile,
                    removeFile: _removeFile,
                    pickFile: _pickFile,
                    isProcessing: _isProcessing,
                    isLoadingPageCount: false,
                    pulseController: _pulseController,
                  ),
                  const SizedBox(height: 16),

                  // Info card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.indigo.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'About This Conversion',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Converts PDF to editable DOCX format\n'
                            '• Preserves text and basic formatting\n'
                            '• Best for text-based PDFs\n'
                            '• Complex layouts may need manual adjustment',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                icon: Icons.description,
                text: _isProcessing ? _statusMessage : 'Convert to DOCX',
                onPressed: _isProcessing ? null : _convertToDocx,
                isProcessing: _isProcessing,
                progress: _progress,
                statusMessage: _statusMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
