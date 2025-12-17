import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FileCard extends StatelessWidget {
  const FileCard({
    super.key,
    this.selectedFile,
    required this.removeFile,
    required this.pickFile,
    required this.isProcessing,
    this.pageCount,
    this.type = 'PDF',
    required this.isLoadingPageCount,
    required this.pulseController,
  });

  final File? selectedFile;
  final String? type;
  final Function() removeFile;
  final Function() pickFile;
  final bool isProcessing;
  final int? pageCount;
  final bool isLoadingPageCount;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    // return Card(
    //   elevation: 2,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //   child: Container(
    //     decoration: BoxDecoration(
    //       gradient: LinearGradient(
    //         begin: Alignment.topLeft,
    //         end: Alignment.bottomRight,
    //         colors: [Colors.blue.shade50, Colors.white],
    //       ),
    //       borderRadius: BorderRadius.circular(16),
    //     ),
    //     padding: const EdgeInsets.all(20.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Row(
    //           children: [
    //             Icon(Icons.picture_as_pdf, color: Colors.blue.shade700),
    //             const SizedBox(width: 8),
    //             const Text(
    //               'Selected File',
    //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //             ),
    //           ],
    //         ),
    //         const SizedBox(height: 16),
    //         if (selectedFile == null) ...[
    //           Center(
    //             child: Column(
    //               children: [
    //                 Container(
    //                   padding: const EdgeInsets.all(20),
    //                   decoration: BoxDecoration(
    //                     color: Colors.blue.shade100,
    //                     shape: BoxShape.circle,
    //                   ),
    //                   child: Icon(
    //                     Icons.upload_file,
    //                     size: 50,
    //                     color: Colors.blue.shade700,
    //                   ),
    //                 ),
    //                 const SizedBox(height: 16),
    //                 Text(
    //                   'No file selected',
    //                   style: TextStyle(
    //                     color: Colors.grey.shade600,
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 const SizedBox(height: 8),
    //                 Text(
    //                   'Tap below to choose a PDF',
    //                   style: TextStyle(
    //                     color: Colors.grey.shade500,
    //                     fontSize: 14,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ] else ...[
    //           Container(
    //             decoration: BoxDecoration(
    //               color: Colors.white,
    //               borderRadius: BorderRadius.circular(12),
    //               border: Border.all(color: Colors.blue.shade200),
    //             ),
    //             child: ListTile(
    //               leading: Container(
    //                 padding: const EdgeInsets.all(8),
    //                 decoration: BoxDecoration(
    //                   color: Colors.blue.shade100,
    //                   borderRadius: BorderRadius.circular(8),
    //                 ),
    //                 child: Icon(Icons.description, color: Colors.blue.shade700),
    //               ),
    //               title: Text(
    //                 selectedFile!.path.split('/').last,
    //                 maxLines: 2,
    //                 overflow: TextOverflow.ellipsis,
    //                 style: const TextStyle(fontWeight: FontWeight.w500),
    //               ),
    //               subtitle: Text(
    //                 '${(selectedFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
    //                 style: TextStyle(color: Colors.grey.shade600),
    //               ),
    //               trailing: IconButton(
    //                 icon: const Icon(Icons.close, color: Colors.red),
    //                 onPressed: removeFile,
    //               ),
    //             ),
    //           ),
    //         ],
    //         const SizedBox(height: 16),
    //         SizedBox(
    //           width: double.infinity,
    //           child: ElevatedButton.icon(
    //             onPressed: isProcessing ? null : pickFile,
    //             icon: const Icon(Icons.folder_open),
    //             label: Text(
    //               selectedFile == null ? 'Select PDF File' : 'Change File',
    //               style: const TextStyle(fontSize: 16),
    //             ),
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: Colors.blue,
    //               foregroundColor: Colors.white,
    //               padding: const EdgeInsets.symmetric(vertical: 16),
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(12),
    //               ),
    //               elevation: 2,
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
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
            if (selectedFile == null) ...[
              Center(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (pulseController.value * 0.1),
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
                      'Tap below to choose a $type file',
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
                    selectedFile!.path.split('/').last,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${(selectedFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      if (isLoadingPageCount)
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
                      else if (pageCount != null)
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
                                    '$pageCount pages',
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
                    onPressed: removeFile,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : pickFile,
                icon: const Icon(Icons.folder_open),
                label: Text(
                  selectedFile == null ? 'Select $type File' : 'Change File',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
}
