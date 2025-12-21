import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/core/utils/extract_zip.dart';
import 'package:smart_pdf_tools/domain/models/pdf_document.dart';
import 'package:smart_pdf_tools/domain/models/split_method.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/error_message.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/file_card.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/method_selector.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/my_appbar.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/primary_button.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/success_dialog.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';
import 'package:vibration/vibration.dart';

class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key});

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen>
    with TickerProviderStateMixin {
  final TextEditingController _rangesController = TextEditingController();
  final TextEditingController _pagesPerSplitController = TextEditingController(
    text: '3',
  );

  File? _selectedFile;
  SplitMethod _selectedMethod = SplitMethod.ranges;
  bool _isProcessing = false;
  bool _isLoadingPageCount = false;
  double _progress = 0.0;
  String _statusMessage = '';
  int? _pageCount;

  late AnimationController _pulseController;
  late AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _rangesController.dispose();
    _pagesPerSplitController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final provider = context.read<DocumentProvider>();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _selectedFile = file;
        _pageCount = null;
        _isLoadingPageCount = true;
      });

      // Get page count with animation
      await _getPageCount(provider: provider, file: file);
    }
  }

  Future<void> _getPageCount({
    required DocumentProvider provider,
    required File file,
  }) async {
    try {
      final count = await provider.getPageCount(file);
      setState(() {
        _pageCount = count;
        _isLoadingPageCount = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPageCount = false;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _pageCount = null;
    });
  }

  Future<void> _splitPdf() async {
    final provider = context.read<DocumentProvider>();
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50);
    }
    if (_selectedFile == null) {
      _showError('Please select a PDF file');
      return;
    }

    // Validate input based on method
    if (_selectedMethod == SplitMethod.ranges) {
      if (_rangesController.text.trim().isEmpty) {
        _showError('Please enter page ranges (e.g., 1-3, 5, 7-10)');
        return;
      }
    } else if (_selectedMethod == SplitMethod.everyN) {
      final pagesPerSplit = int.tryParse(_pagesPerSplitController.text);
      if (pagesPerSplit == null || pagesPerSplit < 1) {
        _showError('Please enter a valid number of pages');
        return;
      }
    }

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _statusMessage = 'Preparing...';
    });

    try {
      String? ranges;
      int? pagesPerSplit;

      if (_selectedMethod == SplitMethod.ranges) {
        ranges = _rangesController.text;
      } else if (_selectedMethod == SplitMethod.everyN) {
        pagesPerSplit = int.parse(_pagesPerSplitController.text);
      }

      final PdfDocument doc = await provider.splitPdf(
        _selectedFile!,
        method: _selectedMethod,
        ranges: ranges,
        pagesPerSplit: pagesPerSplit,
        onProgress: (progress) {
          setState(() {
            _progress = progress;
            if (progress < 0.5) {
              _statusMessage = 'Uploading PDF...';
            } else if (progress < 0.9) {
              _statusMessage = 'Splitting pages...';
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

      _successController.forward(from: 0);

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        final player = AudioPlayer();
        await player.play(AssetSource('sounds/success.mp3'));
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SuccessDialog(
            filePath: doc.path,
            removeFile: _removeFile,
            title: 'Split Complete!',
            description: 'Your PDF has been split successfully',
            removeText: 'Done',
            openFileText: 'Extract',
            onPressed: () => extractZip(filePath: doc.path),
          ).animate().scale(duration: 300.ms, curve: Curves.easeOut),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Failed';
      });

      if (mounted) {
        _showError('Failed to split PDF: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(errorMessageSnackBar(message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, title: 'PDF Splitter'),
      body: Column(
        children: [
          // Content
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
                    isLoadingPageCount: _isLoadingPageCount,
                    pageCount: _pageCount,
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
                              Icon(
                                Icons.content_cut,
                                color: Colors.teal.shade700,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Split Method',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Method 1: Ranges
                          MethodSelector(
                            method: SplitMethod.ranges,
                            icon: Icons.format_list_numbered,
                            title: 'By Page Ranges',
                            subtitle: 'Extract specific page ranges',
                            example: 'e.g., 1-3, 5, 7-10',
                            onTap: () {
                              setState(() {
                                _selectedMethod = SplitMethod.ranges;
                              });
                            },
                            onChanged: (SplitMethod? value) {
                              setState(() {
                                _selectedMethod = SplitMethod.ranges;
                              });
                            },
                            isSelected: _selectedMethod == SplitMethod.ranges,
                            selectedMethod: _selectedMethod,
                          ),
                          if (_selectedMethod == SplitMethod.ranges) ...[
                            Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    16,
                                  ),
                                  child: TextField(
                                    controller: _rangesController,
                                    decoration: InputDecoration(
                                      hintText: '1-3, 5, 7-10',
                                      prefixIcon: const Icon(Icons.edit),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      suffixIcon: _pageCount != null
                                          ? Tooltip(
                                              message:
                                                  'Total pages: $_pageCount',
                                              child: Container(
                                                margin: const EdgeInsets.all(8),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '$_pageCount pg',
                                                  style: TextStyle(
                                                    color: Colors.blue.shade700,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideY(begin: -0.2, end: 0),
                          ],

                          const Divider(height: 24),

                          // Method 2: Individual
                          MethodSelector(
                            method: SplitMethod.individual,
                            icon: Icons.filter_1,
                            title: 'Individual Pages',
                            subtitle: 'Create one file per page',
                            example: 'Best for extracting all pages',
                            onTap: () {
                              setState(() {
                                _selectedMethod = SplitMethod.individual;
                              });
                            },
                            onChanged: (SplitMethod? value) {
                              setState(() {
                                _selectedMethod = SplitMethod.individual;
                              });
                            },
                            isSelected:
                                _selectedMethod == SplitMethod.individual,
                            selectedMethod: _selectedMethod,
                          ),

                          const Divider(height: 24),

                          // Method 3: Every N
                          MethodSelector(
                            method: SplitMethod.everyN,
                            icon: Icons.grid_view,
                            title: 'Every N Pages',
                            subtitle: 'Split into equal chunks',
                            example: 'Divide PDF into sections',
                            onTap: () {
                              setState(() {
                                _selectedMethod = SplitMethod.everyN;
                              });
                            },
                            onChanged: (SplitMethod? value) {
                              setState(() {
                                _selectedMethod = SplitMethod.everyN;
                              });
                            },
                            isSelected: _selectedMethod == SplitMethod.everyN,
                            selectedMethod: _selectedMethod,
                          ),
                          if (_selectedMethod == SplitMethod.everyN) ...[
                            Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    16,
                                  ),
                                  child: TextField(
                                    controller: _pagesPerSplitController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Pages per chunk',
                                      hintText: '3',
                                      prefixIcon: const Icon(Icons.functions),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideY(begin: -0.2, end: 0),
                          ],
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
                icon: Icons.content_cut,
                text: _isProcessing ? _statusMessage : 'Split PDF',
                onPressed: _isProcessing ? null : _splitPdf,
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
