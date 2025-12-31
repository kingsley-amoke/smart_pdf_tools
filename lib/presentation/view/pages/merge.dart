import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/core/utils/save_file.dart';
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/clear_items.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/empty_selection.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/error_message.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/my_appbar.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/pdf_card.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/primary_button.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/secondary_button.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/success_dialog.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/total_files_footer.dart';
import 'dart:io';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MergeScreen extends StatefulWidget {
  const MergeScreen({super.key});

  @override
  State<MergeScreen> createState() => _MergeScreenState();
}

class _MergeScreenState extends State<MergeScreen> {
  final List<File> _selectedFiles = [];
  bool _isProcessing = false;
  double _progress = 0.0;
  String _statusMessage = '';

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _clearAll() {
    setState(() {
      _selectedFiles.clear();
    });
  }

  void _reorderFiles(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedFiles.removeAt(oldIndex);
      _selectedFiles.insert(newIndex, item);
    });
  }

  Future<void> _mergePdfs() async {
    final provider = context.read<DocumentProvider>();
    if (_selectedFiles.length < 2) {
      _showError('Please select at least 2 PDF files');
      return;
    }

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _statusMessage = 'Merging PDFs...';
    });

    try {
      final PdfDocument doc = await provider.mergePdfs(
        _selectedFiles,
        onProgress: (progress) {
          setState(() {
            _progress = progress;
            if (progress < 0.5) {
              _statusMessage = 'Uploading...';
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
            removeFile: () => Navigator.pop(context),
            title: 'Merge Complete!',
            description: 'Your PDFs have been merged successfully',
            removeText: 'Done',
            openFileText: 'Download',
            onPressed: () => saveLocalFileToDownloads(context, doc),
          ).animate().scale(duration: 300.ms, curve: Curves.easeOut),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Error: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to merge PDFs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(errorMessageSnackBar(message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, title: 'PDF Merger', centerTitle: true),
      body: Column(
        children: [
          // File list
          Expanded(
            child: _selectedFiles.isEmpty
                ? EmptySelection(icon: Icons.picture_as_pdf, type: 'PDF')
                : PdfCard(
                    selectedFiles: _selectedFiles,
                    removeFile: _removeFile,
                    reorderFiles: _reorderFiles,
                  ),
          ),
          const SizedBox(height: 12),

          if (_selectedFiles.isNotEmpty) ...[
            ClearItems(onTap: _clearAll),
            TotalFilesFooter(selectedFiles: _selectedFiles),
          ],

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        icon: Icons.add,
                        text: 'Add Files',
                        onPressed: _isProcessing ? null : _pickFiles,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        icon: Icons.merge,
                        text: _isProcessing ? _statusMessage : 'Merge PDFs',
                        onPressed: _isProcessing ? null : _mergePdfs,
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
