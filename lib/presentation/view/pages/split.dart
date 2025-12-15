import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/core/utils/open_file.dart';
import 'package:smart_pdf_tools/domain/models/split_method.dart';
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
      print('Failed to get page count: $e');
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _pageCount = null;
    });
  }

  Future<void> _splitPdf() async {
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

      final resultPath = await context.read<DocumentProvider>().splitPdf(
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
        _showSuccessDialog(resultPath);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog(String filePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 64,
                    ),
                  )
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.elasticOut)
                  .then()
                  .shake(duration: 300.ms),
              const SizedBox(height: 20),
              const Text(
                'Split Complete!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Your PDF has been split successfully',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder_zip, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        filePath.split('/').last,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _removeFile();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await openFile(filePath);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Open ZIP'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildFileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal.shade50, Colors.white],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Selected File',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedFile == null) ...[
              Center(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.1),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.upload_file,
                              size: 50,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No file selected',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap below to choose a PDF',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.description, color: Colors.teal.shade700),
                  ),
                  title: Text(
                    _selectedFile!.path.split('/').last,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${(_selectedFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      if (_isLoadingPageCount)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.teal.shade600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Counting pages...',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      else if (_pageCount != null)
                        Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.insert_drive_file,
                                    size: 14,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_pageCount pages',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: -0.2, end: 0),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: _removeFile,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _pickFile,
                icon: const Icon(Icons.folder_open),
                label: Text(
                  _selectedFile == null ? 'Select PDF File' : 'Change File',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.content_cut, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Split Method',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Method 1: Ranges
            _buildMethodOption(
              method: SplitMethod.ranges,
              icon: Icons.format_list_numbered,
              title: 'By Page Ranges',
              subtitle: 'Extract specific page ranges',
              example: 'e.g., 1-3, 5, 7-10',
            ),
            if (_selectedMethod == SplitMethod.ranges) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                            message: 'Total pages: $_pageCount',
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
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
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
            ],

            const Divider(height: 24),

            // Method 2: Individual
            _buildMethodOption(
              method: SplitMethod.individual,
              icon: Icons.filter_1,
              title: 'Individual Pages',
              subtitle: 'Create one file per page',
              example: 'Best for extracting all pages',
            ),

            const Divider(height: 24),

            // Method 3: Every N
            _buildMethodOption(
              method: SplitMethod.everyN,
              icon: Icons.grid_view,
              title: 'Every N Pages',
              subtitle: 'Split into equal chunks',
              example: 'Divide PDF into sections',
            ),
            if (_selectedMethod == SplitMethod.everyN) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption({
    required SplitMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
    required String example,
  }) {
    final isSelected = _selectedMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.teal.shade300 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<SplitMethod>(
              value: method,
              groupValue: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
              activeColor: Colors.teal.shade700,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.teal.shade700 : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? Colors.teal.shade900 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    example,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split PDF'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Animated progress indicator
          if (_isProcessing) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade400, Colors.teal.shade600],
                ),
              ),
              child: Column(
                children: [
                  Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: _progress,
                              strokeWidth: 6,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            '${(_progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 1500.ms,
                        color: Colors.white.withOpacity(0.3),
                      ),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                ],
              ),
            ),
          ],

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFileCard(),
                  const SizedBox(height: 16),
                  _buildMethodSelector(),
                ],
              ),
            ),
          ),

          // Bottom button with gradient
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: (_isProcessing || _selectedFile == null)
                      ? [Colors.grey.shade400, Colors.grey.shade500]
                      : [Colors.teal.shade400, Colors.teal.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: (_isProcessing || _selectedFile == null)
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.teal.shade300.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (_isProcessing || _selectedFile == null)
                      ? null
                      : _splitPdf,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isProcessing) ...[
                          const Icon(
                            Icons.content_cut,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          _isProcessing ? 'Processing...' : 'Split PDF',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
