import 'dart:io';

import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    super.key,
    required this.selectedImages,
    required this.removeImage,
    required this.reorderImages,
  });

  final List<File> selectedImages;
  final void Function(int) removeImage;
  final void Function(int, int) reorderImages;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: selectedImages.length,
        onReorder: reorderImages,
        itemBuilder: (context, index) {
          final image = selectedImages[index];
          final fileName = image.path.split('/').last;
          final fileSize = (image.lengthSync() / 1024).toStringAsFixed(1);

          return Card(
            key: ValueKey(image.path),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              title: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('$fileSize KB'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.drag_handle, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => removeImage(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
