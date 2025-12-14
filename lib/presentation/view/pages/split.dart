import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smart_pdf_tools/core/utils/open_file.dart';
import 'dart:io';
import 'package:smart_pdf_tools/data/apis/api_service.dart';

enum SplitMethod { ranges, individual, everyN }

class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key});

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _rangesController = TextEditingController();
  final TextEditingController _pagesPerSplitController = TextEditingController(
    text: '3',
  );

  File? _selectedFile;
  SplitMethod _selectedMethod = SplitMethod.ranges;
  bool _isProcessing = false;
  double _progress = 0.0;
  String _statusMessage = '';
  int? _pageCount;

  @override
  void dispose() {
    _rangesController.dispose();
    _pagesPerSplitController.dispose();
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
        _pageCount = null;
      });

      // Get page count
      _getPageCount(file);
    }
  }

  Future<void> _getPageCount(File file) async {
    try {
      final count = await _apiService.getPageCount(file);
      setState(() {
        _pageCount = count;
      });
    } catch (e) {
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
      _statusMessage = 'Splitting PDF...';
    });

    try {
      String? ranges;
      int? pagesPerSplit;

      if (_selectedMethod == SplitMethod.ranges) {
        ranges = _rangesController.text;
      } else if (_selectedMethod == SplitMethod.everyN) {
        pagesPerSplit = int.parse(_pagesPerSplitController.text);
      }

      final resultPath = await _apiService.splitPdf(
        _selectedFile!,
        method: _selectedMethod,
        ranges: ranges,
        pagesPerSplit: pagesPerSplit,
        onProgress: (progress) {
          setState(() {
            _progress = progress;
            if (progress < 0.5) {
              _statusMessage = 'Uploading... ${(progress * 100).toInt()}%';
            } else {
              _statusMessage = 'Downloading... ${(progress * 100).toInt()}%';
            }
          });
        },
      );

      setState(() {
        _isProcessing = false;
        _statusMessage = 'Success!';
      });

      if (mounted) {
        _showSuccessDialog(resultPath);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Error: $e';
      });

      if (mounted) {
        _showError('Failed to split PDF: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Success!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PDF split successfully!'),
            const SizedBox(height: 12),
            Text(
              'Saved as ZIP:\n${filePath.split('/').last}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFile();
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openFile(filePath);
            },
            child: const Text('Open ZIP'),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Split Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RadioListTile<SplitMethod>(
              title: const Text('By Page Ranges'),
              subtitle: const Text('e.g., 1-3, 5, 7-10'),
              value: SplitMethod.ranges,
              groupValue: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),
            if (_selectedMethod == SplitMethod.ranges) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _rangesController,
                  decoration: InputDecoration(
                    hintText: '1-3, 5, 7-10',
                    border: const OutlineInputBorder(),
                    suffixIcon: _pageCount != null
                        ? Tooltip(
                            message: 'Total pages: $_pageCount',
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            RadioListTile<SplitMethod>(
              title: const Text('Individual Pages'),
              subtitle: const Text('One page per file'),
              value: SplitMethod.individual,
              groupValue: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),
            RadioListTile<SplitMethod>(
              title: const Text('Every N Pages'),
              subtitle: const Text('Split into equal chunks'),
              value: SplitMethod.everyN,
              groupValue: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),
            if (_selectedMethod == SplitMethod.everyN) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _pagesPerSplitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Pages per split',
                    hintText: '3',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
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
      ),
      body: Column(
        children: [
          // Progress indicator
          if (_isProcessing) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // File selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selected File',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_selectedFile == null) ...[
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No file selected',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.teal,
                                child: Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                _selectedFile!.path.split('/').last,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${(_selectedFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                                  ),
                                  if (_pageCount != null)
                                    Text(
                                      '$_pageCount pages',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: _removeFile,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isProcessing ? null : _pickFile,
                              icon: const Icon(Icons.upload_file),
                              label: Text(
                                _selectedFile == null
                                    ? 'Select PDF'
                                    : 'Change File',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Method selector
                  _buildMethodSelector(),
                ],
              ),
            ),
          ),

          // Bottom button
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
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (_isProcessing || _selectedFile == null)
                    ? null
                    : _splitPdf,
                icon: const Icon(Icons.content_cut),
                label: const Text('Split PDF', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
