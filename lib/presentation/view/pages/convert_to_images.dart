import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/core/utils/extract_zip.dart';
import 'dart:io';

import 'package:smart_pdf_tools/domain/models/image_format.dart';
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/custom_slider.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/error_message.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/file_card.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/image_format_card.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/my_appbar.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/primary_button.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/success_dialog.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class ConvertToImagesScreen extends StatefulWidget {
  const ConvertToImagesScreen({super.key});

  @override
  State<ConvertToImagesScreen> createState() => _ConvertToImagesScreenState();
}

class _ConvertToImagesScreenState extends State<ConvertToImagesScreen>
    with TickerProviderStateMixin {
  File? _selectedFile;
  ImageFormat _selectedFormat = ImageFormat.png;
  double _quality = 90;
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

  Future<void> _convertToImages() async {
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
      final PdfDocument doc = await context
          .read<DocumentProvider>()
          .convertPdfToImages(
            _selectedFile!,
            format: _selectedFormat,
            quality: _quality.toInt(),
            onProgress: (progress) {
              setState(() {
                _progress = progress;
                if (progress < 0.5) {
                  _statusMessage = 'Uploading PDF...';
                } else if (progress < 0.9) {
                  _statusMessage = 'Converting pages...';
                } else {
                  _statusMessage = 'Creating ZIP...';
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
            title: 'Conversion Complete!',
            description: 'Your PDF has been converted to images',
            removeText: 'Done',
            openFileText: 'Extract',
            filePath: doc.path,
            removeFile: _removeFile,
            onPressed: () => extractZip(filePath: doc.path),
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
      appBar: myAppbar(context, title: 'PDF to Image Converter'),
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
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              const Text(
                                'Conversion Options',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Format selector
                          const Text(
                            'Image Format',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ImageFormatCard(
                                  selectedFormat: _selectedFormat,

                                  format: ImageFormat.png,
                                  title: 'PNG',
                                  subtitle: 'Lossless quality',
                                  icon: Icons.image,
                                  onTap: _isProcessing
                                      ? null
                                      : (ImageFormat format) {
                                          setState(() {
                                            _selectedFormat = format;
                                          });
                                        },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ImageFormatCard(
                                  selectedFormat: _selectedFormat,

                                  format: ImageFormat.jpg,
                                  title: 'JPG',
                                  subtitle: 'Smaller size',
                                  icon: Icons.photo,
                                  onTap: _isProcessing
                                      ? null
                                      : (ImageFormat format) {
                                          setState(() {
                                            _selectedFormat = format;
                                          });
                                        },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Quality slider
                          const Text(
                            'Image Quality',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomSlider(
                            value: _quality,
                            onChanged: _isProcessing
                                ? null
                                : (value) {
                                    setState(() {
                                      _quality = value;
                                    });
                                  },
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
                icon: Icons.image,
                text: _isProcessing ? _statusMessage : 'Convert to Images',
                onPressed: _isProcessing ? null : _convertToImages,
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
