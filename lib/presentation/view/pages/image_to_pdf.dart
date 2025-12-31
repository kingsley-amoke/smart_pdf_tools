import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/core/utils/save_file.dart';
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/clear_items.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/empty_selection.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/error_message.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/image_card.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/my_appbar.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/primary_button.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/secondary_button.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/success_dialog.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/total_files_footer.dart';
import 'dart:io';

import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class ImagesToPdfScreen extends StatefulWidget {
  const ImagesToPdfScreen({super.key});

  @override
  State<ImagesToPdfScreen> createState() => _ImagesToPdfScreenState();
}

class _ImagesToPdfScreenState extends State<ImagesToPdfScreen> {
  final List<File> _selectedImages = [];
  bool _isProcessing = false;
  double _progress = 0.0;
  String _statusMessage = '';

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedImages.addAll(
          result.paths.map((path) => File(path!)).toList(),
        );
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedImages.removeAt(oldIndex);
      _selectedImages.insert(newIndex, item);
    });
  }

  void _clearAll() {
    setState(() {
      _selectedImages.clear();
    });
  }

  Future<void> _convertToPdf() async {
    if (_selectedImages.isEmpty) {
      _showError('Please select at least one image');
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
          .convertImagesToPdf(
            _selectedImages,
            onProgress: (progress) {
              setState(() {
                _progress = progress;
                if (progress < 0.5) {
                  _statusMessage = 'Uploading...';
                } else if (progress < 0.9) {
                  _statusMessage = 'Creating PDF...';
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
        final player = AudioPlayer();
        await player.play(AssetSource('sounds/success.mp3'));
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SuccessDialog(
            filePath: doc.path,
            removeFile: () {
              Navigator.pop(context);
              _clearAll();
            },
            title: 'Conversion Complete!',
            description: 'Your images have been converted to PDF',
            removeText: 'Done',
            openFileText: 'Download',
            onPressed: () => saveLocalFileToDownloads(context, doc),
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
      appBar: myAppbar(context, title: 'Image to PDF Converter', centerTitle: true),
      body: Column(
        children: [
          // Image list
          Expanded(
            child: _selectedImages.isEmpty
                ? EmptySelection(icon: Icons.add_photo_alternate, type: 'image')
                : Column(
                    children: [
                      // Info banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.purple.shade50,
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.purple.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Drag to reorder images. Order will be preserved in PDF.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      ImageCard(
                        selectedImages: _selectedImages,
                        removeImage: _removeImage,
                        reorderImages: _reorderImages,
                      ),
                    ],
                  ),
          ),
          if (_selectedImages.isNotEmpty) ...[
            if (!_isProcessing) ClearItems(onTap: _clearAll),
            TotalFilesFooter(selectedFiles: _selectedImages),
            const SizedBox(height: 16),
          ],

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        icon: Icons.add_photo_alternate,
                        text: 'Add',
                        onPressed: _isProcessing ? null : _pickImages,
                      ),
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        icon: Icons.picture_as_pdf,
                        text: _isProcessing ? _statusMessage : 'Convert',
                        onPressed: _isProcessing ? null : _convertToPdf,
                        isProcessing: _isProcessing,
                        progress: _progress,
                        statusMessage: _statusMessage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
