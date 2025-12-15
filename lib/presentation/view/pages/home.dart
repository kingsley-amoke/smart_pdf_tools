import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/presentation/view/pages/compress.dart';
import 'package:smart_pdf_tools/presentation/view/pages/merge.dart';
import 'package:smart_pdf_tools/presentation/view/pages/split.dart';

import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final ApiService _apiService = ApiService();
  String _statusMessage = '';
  final bool _isUploading = false;
  final double _uploadProgress = 0.0;

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status indicator
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isConnected ? Colors.green.shade50 : Colors.red.shade50,
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
          ],
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                      context: context,
                      title: 'Merge PDFs',
                      subtitle: 'Combine multiple files',
                      icon: Icons.merge_type,
                      color: Colors.deepPurple,
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.deepPurple.shade600,
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MergeScreen(),
                          ),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 0.ms)
                    .slideY(begin: 0.2, end: 0),
                _buildFeatureCard(
                      context: context,
                      title: 'Split PDF',
                      subtitle: 'Extract pages',
                      icon: Icons.content_cut,
                      color: Colors.teal,
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade400, Colors.teal.shade600],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SplitScreen(),
                          ),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 100.ms)
                    .slideY(begin: 0.2, end: 0),

                _buildFeatureCard(
                      context: context,
                      title: 'Compress',
                      subtitle: 'Reduce file size',
                      icon: Icons.compress,
                      color: Colors.orange,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.orange.shade600,
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CompressScreen(),
                          ),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 200.ms)
                    .slideY(begin: 0.2, end: 0),

                _buildFeatureCard(
                      context: context,
                      title: 'Convert',
                      subtitle: 'PDF to images',
                      icon: Icons.transform,
                      color: Colors.blue,
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon!')),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 300.ms)
                    .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
