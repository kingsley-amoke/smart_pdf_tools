import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final picker = ImagePicker();

  Future<List<File>> importImages() async {
    final List<XFile> images = await picker.pickMultiImage();
    return images.map((e) => File(e.path)).toList();
  }

  Future<File?> captureImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    return image != null ? File(image.path) : null;
  }
}
