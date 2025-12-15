import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/core/utils/open_file.dart';
import 'dart:io';
import 'package:smart_pdf_tools/domain/models/compression_quality.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class CompressScreen extends StatefulWidget {
  const CompressScreen({super.key});

  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  File? _selectedFile;
  CompressionQuality _selectedQuality = CompressionQuality.medium;
  bool _compressImages = true;
  bool _removeMetadata = true;
  bool _isProcessing = false;
  double _progress = 0.0;
  String _statusMessage = '';

  int? _originalSize;
  int? _compressedSize;
  String? _reductionPercentage;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _selectedFile = file;
        _originalSize = file.lengthSync();
        _compressedSize = null;
        _reductionPercentage = null;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _originalSize = null;
      _compressedSize = null;
      _reductionPercentage = null;
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
      _compressedSize = null;
      _reductionPercentage = null;
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
        _compressedSize = result['compressedSize'];
        _reductionPercentage = result['reductionPercentage'];
      });

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        _showSuccessDialog(result['filePath']);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Failed';
      });

      if (mounted) {
        _showError('Failed to compress PDF: $e');
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
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
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
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Compression Complete!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Your PDF has been compressed successfully',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),

              // Size comparison
              if (_originalSize != null && _compressedSize != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Original',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(_originalSize! / 1024 / 1024).toStringAsFixed(2)} MB',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.orange.shade700,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Compressed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(_compressedSize! / 1024 / 1024).toStringAsFixed(2)} MB',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_down,
                              color: Colors.green.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_reductionPercentage}% smaller',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 20),
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
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Open PDF'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
            colors: [Colors.orange.shade50, Colors.white],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.orange.shade700),
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
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.upload_file,
                        size: 50,
                        color: Colors.orange.shade700,
                      ),
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
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.description,
                      color: Colors.orange.shade700,
                    ),
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
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: _removeFile,
                  ),
                ),
              ),
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
                  backgroundColor: Colors.orange,
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

  Widget _buildQualitySelector() {
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
                Icon(Icons.tune, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Compression Quality',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildQualityOption(
              quality: CompressionQuality.low,
              title: 'Maximum Compression',
              subtitle: 'Smallest file size',
              description: 'Best for email and web',
              icon: Icons.compress,
              color: Colors.green,
            ),
            const SizedBox(height: 12),

            _buildQualityOption(
              quality: CompressionQuality.medium,
              title: 'Balanced',
              subtitle: 'Good quality & size',
              description: 'Recommended for most uses',
              icon: Icons.balance,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),

            _buildQualityOption(
              quality: CompressionQuality.high,
              title: 'Minimum Compression',
              subtitle: 'Best quality',
              description: 'For printing and archiving',
              icon: Icons.high_quality,
              color: Colors.purple,
            ),

            const Divider(height: 32),

            Row(
              children: [
                Icon(Icons.settings, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Options',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            CheckboxListTile(
              title: const Text('Compress Images'),
              subtitle: const Text('Reduce image quality for smaller size'),
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
              subtitle: const Text('Strip author, date, and other info'),
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
    );
  }

  Widget _buildQualityOption({
    required CompressionQuality quality,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedQuality == quality;

    return InkWell(
      onTap: _isProcessing
          ? null
          : () {
              setState(() {
                _selectedQuality = quality;
              });
            },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<CompressionQuality>(value: quality, activeColor: color),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
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
        title: const Text('PDF Compressor'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFileCard(),
            const SizedBox(height: 20),
            _buildQualitySelector(),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _compressPdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              value: _progress,
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(_statusMessage),
                        ],
                      )
                    : const Text(
                        'Compress PDF',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
