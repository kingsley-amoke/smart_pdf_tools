import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/presentation/view/pages/merge.dart';
import 'package:smart_pdf_tools/presentation/view/pages/split.dart';
import 'package:smart_pdf_tools/presentation/view/widgets/primary_button.dart';
import 'dart:io';

import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final ApiService _apiService = ApiService();
  String _statusMessage = '';
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final connected = await context.watch<DocumentProvider>().checkConnection();
    setState(() {
      _statusMessage = connected
          ? 'Connected to server'
          : 'Cannot connect to server';
    });
  }

  Future<void> _pickAndUploadSingleFile(BuildContext context) async {
    final provider = context.read<DocumentProvider>();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _statusMessage = 'Uploading ${result.files.single.name}...';
      });

      try {
        final response = await provider.uploadSingleFile(
          file,
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
            });
          },
        );

        setState(() {
          _isUploading = false;
          _statusMessage = '✅ ${response['message']}';
        });

        _showSuccessDialog(response);
      } catch (e) {
        setState(() {
          _isUploading = false;
          _statusMessage = '❌ Error: $e';
        });
      }
    }
  }

  Future<void> _pickAndUploadMultipleFiles() async {
    final provider = context.read<DocumentProvider>();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _statusMessage = 'Uploading ${files.length} files...';
      });

      try {
        final response = await provider.uploadMultipleFiles(
          files,
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
            });
          },
        );

        setState(() {
          _isUploading = false;
          _statusMessage = '✅ ${response['message']}';
        });

        _showSuccessDialog(response);
      } catch (e) {
        setState(() {
          _isUploading = false;
          _statusMessage = '❌ Error: $e';
        });
      }
    }
  }

  void _showSuccessDialog(Map<String, dynamic> response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Success'),
        content: Text(response.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<DocumentProvider>().isConnected;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Utility Tool'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          Consumer<DocumentProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isConnected ? Icons.cloud_done : Icons.cloud_off,
                ),
                onPressed: () => provider.checkConnection(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isConnected
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isConnected ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.check_circle : Icons.error,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusMessage.isEmpty
                            ? (isConnected
                                  ? 'Ready to upload PDFs'
                                  : 'Server not connected')
                            : _statusMessage,
                        style: TextStyle(
                          color: isConnected
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Upload progress
              if (_isUploading) ...[
                LinearProgressIndicator(
                  value: _uploadProgress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
              ],

              // Upload buttons
              SizedBox(
                width: double.infinity,
                height: 60,
                child: PrimaryButton(
                  icon: Icons.upload_file,
                  text: 'Upload Single PDF',
                  onPressed: _isUploading
                      ? null
                      : () => _pickAndUploadSingleFile(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: PrimaryButton(
                  icon: Icons.file_copy,
                  text: 'Upload Multiple PDFs',
                  iconSize: 28,
                  fontSize: 18,
                  onPressed: _isUploading ? null : _pickAndUploadMultipleFiles,
                  backgroundColor: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 70,
                child: PrimaryButton(
                  icon: Icons.merge_type,
                  text: 'Merge PDFs',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MergeScreen(),
                      ),
                    ),
                  },
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 70,
                child: PrimaryButton(
                  icon: Icons.content_cut,
                  text: 'Split PDF',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SplitScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
