import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/core/utils/save_file.dart';
import 'dart:io';
import 'package:smart_pdf_tools/domain/models/compression_quality.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/error_message.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/file_card.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/my_appbar.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/primary_button.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/quality_option.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/success_dialog.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class CompressScreen extends StatefulWidget {
  const CompressScreen({super.key});

  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen>
    with TickerProviderStateMixin {
  File? _selectedFile;
  CompressionQuality _selectedQuality = CompressionQuality.medium;
  bool _compressImages = true;
  bool _removeMetadata = true;
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
      final file = File(result.files.single.path!);
      setState(() {
        _selectedFile = file;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  Future<void> _compressPdf() async {
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
      final result = await context.read<DocumentProvider>().compressPdf(
        _selectedFile!,
        quality: _selectedQuality,
        compressImages: _compressImages,
        removeMetadata: _removeMetadata,
        onProgress: (progress) {

          setState(() {
            _progress = progress;
            if (progress < 0.5) {
              _statusMessage = 'Uploading PDF...';
            } else if (progress < 0.9) {
              _statusMessage = 'Compressing...';
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
            filePath: result['filePath'],
            removeFile: _removeFile,
            title: 'Compression Complete!',
            description: 'Your PDF has been compressed successfully',
            removeText: 'Done',
            openFileText: 'Download',
            onPressed: () => saveLocalFileToDownloads(context, result['doc']),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Failed';
      });

      if (mounted) {
        _showError('Failed to compress PDF');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(errorMessageSnackBar(message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, title: 'PDF Compressor',centerTitle: true),

      body: SingleChildScrollView(
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
            const SizedBox(height: 20),
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
                        Icon(Icons.tune, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Compression Quality',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    QualityOption(
                      quality: CompressionQuality.low,
                      title: 'Maximum Compression',
                      subtitle: 'Smallest file size',
                      description: 'Best for email and web',
                      icon: Icons.compress,
                      color: Colors.green,
                      isSelected: _selectedQuality == CompressionQuality.low,
                      selectedQuality: _selectedQuality,
                      onTap: () {
                        setState(() {
                          _selectedQuality = CompressionQuality.low;
                        });
                      },
                      onChanged: (CompressionQuality value) {
                        setState(() {
                          _selectedQuality = CompressionQuality.low;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    QualityOption(
                      quality: CompressionQuality.medium,
                      title: 'Balanced',
                      subtitle: 'Good quality & size',
                      description: 'Recommended for most uses',
                      icon: Icons.balance,
                      color: Colors.blue,
                      isSelected: _selectedQuality == CompressionQuality.medium,
                      selectedQuality: _selectedQuality,
                      onTap: () {
                        setState(() {
                          _selectedQuality = CompressionQuality.medium;
                        });
                      },
                      onChanged: (CompressionQuality value) {
                        setState(() {
                          _selectedQuality = CompressionQuality.medium;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    QualityOption(
                      quality: CompressionQuality.high,
                      title: 'Minimum Compression',
                      subtitle: 'Best quality',
                      description: 'For printing and archiving',
                      icon: Icons.high_quality,
                      color: Colors.purple,
                      isSelected: _selectedQuality == CompressionQuality.high,
                      selectedQuality: _selectedQuality,
                      onTap: () {
                        setState(() {
                          _selectedQuality = CompressionQuality.high;
                        });
                      },
                      onChanged: (CompressionQuality value) {
                        setState(() {
                          _selectedQuality = CompressionQuality.high;
                        });
                      },
                    ),

                    const Divider(height: 32),

                    Row(
                      children: [
                        Icon(
                          Icons.settings,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Options',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    CheckboxListTile(
                      title: const Text('Compress Images'),
                      subtitle: const Text(
                        'Reduce image quality for smaller size',
                      ),
                      value: _compressImages,
                      onChanged: _isProcessing
                          ? null
                          : (value) {
                              setState(() {
                                _compressImages = value!;
                              });
                            },
                      activeColor: Colors.orange,
                    ),

                    CheckboxListTile(
                      title: const Text('Remove Metadata'),
                      subtitle: const Text(
                        'Strip author, date, and other info',
                      ),
                      value: _removeMetadata,
                      onChanged: _isProcessing
                          ? null
                          : (value) {
                              setState(() {
                                _removeMetadata = value!;
                              });
                            },
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              icon: Icons.compress,
              text: _isProcessing ? _statusMessage : 'Compress PDF',
              onPressed: _isProcessing ? null : _compressPdf,
              isProcessing: _isProcessing,
              progress: _progress,
              statusMessage: _statusMessage,
            ),
          ],
        ),
      ),
    );
  }
}
