import 'dart:io';

import 'package:dio/dio.dart';
import 'package:smart_pdf_tools/core/utils/create_app_folder.dart';
import 'package:smart_pdf_tools/domain/models/image_format.dart';
import 'package:smart_pdf_tools/domain/usecases/convert_pdf.dart';

class ConvertPdfApi extends ConvertPdf {
  final Dio dio;

  ConvertPdfApi({required this.dio});

  @override
  Future<String> pdfToDoc({
    required File file,
    required Function(double) onProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final directory = await createAppFolder();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = '$directory/converted_$timestamp.docx';

      await dio
          .post(
            '/pdf/convert/to-docx',
            data: formData,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ),
            onSendProgress: (sent, total) {
              final progress = sent / total * 0.5;
              onProgress(progress);
            },
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = 0.5 + (received / total * 0.5);
                onProgress(progress);
              }
            },
          )
          .then((response) async {
            if (response.statusCode == 200 || response.statusCode == 201) {
              final file = File(savePath);
              await file.writeAsBytes(response.data);
            } else {
              throw Exception('Server returned status: ${response.statusCode}');
            }
          });

      return savePath;
    } catch (e) {
      throw Exception('Failed to convert PDF to DOCX: $e');
    }
  }

  @override
  Future<String> imagesToPdf({
    required List<File> files,
    required Function(double) onProgress,
  }) async {
    try {
      List<MultipartFile> filesList = [];
      for (var file in files) {
        filesList.add(
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        );
      }

      FormData formData = FormData.fromMap({'files': filesList});

      final directory = await createAppFolder();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = '$directory/from_images_$timestamp.pdf';

      await dio
          .post(
            '/pdf/convert/images-to-pdf',
            data: formData,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ),
            onSendProgress: (sent, total) {
              final progress = sent / total * 0.5;
              onProgress(progress);
            },
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = 0.5 + (received / total * 0.5);
                onProgress(progress);
              }
            },
          )
          .then((response) async {
            if (response.statusCode == 200 || response.statusCode == 201) {
              final file = File(savePath);
              await file.writeAsBytes(response.data);
            } else {
              throw Exception('Server returned status: ${response.statusCode}');
            }
          });

      return savePath;
    } catch (e) {
      throw Exception('Failed to convert images to PDF: $e');
    }
  }

  @override
  Future<String> docToPdf({
    required File file,
    required Function(double) onProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });
      final directory = await createAppFolder();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = '$directory/converted_$timestamp.pdf';

      await dio
          .post(
            '/pdf/convert/docx-to-pdf',
            data: formData,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ),
            onSendProgress: (sent, total) {
              final progress = sent / total * 0.5;
              onProgress(progress);
            },
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = 0.5 + (received / total * 0.5);
                onProgress(progress);
              }
            },
          )
          .then((response) async {
            if (response.statusCode == 200 || response.statusCode == 201) {
              final file = File(savePath);
              await file.writeAsBytes(response.data);
            } else {
              throw Exception('Server returned status: ${response.statusCode}');
            }
          });

      return savePath;
    } catch (e) {
      throw Exception('Failed to convert DOCX to PDF: $e');
    }
  }

  @override
  Future<String> pdfToImages({
    required File file,
    required ImageFormat format,
    int quality = 90,
    required Function(double) onProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'format': format.name,
        'quality': quality,
      });

      final directory = await createAppFolder();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = '$directory/pdf_images_$timestamp.zip';

      await dio
          .post(
            '/pdf/convert/to-images',
            data: formData,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ),
            onSendProgress: (sent, total) {
              final progress = sent / total * 0.5;
              onProgress(progress);
            },
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = 0.5 + (received / total * 0.5);
                onProgress(progress);
              }
            },
          )
          .then((response) async {
            if (response.statusCode == 200 || response.statusCode == 201) {
              final file = File(savePath);
              await file.writeAsBytes(response.data);
            } else {
              throw Exception('Server returned status: ${response.statusCode}');
            }
          });

      return savePath;
    } catch (e) {
      throw Exception('Failed to convert PDF to images: $e');
    }
  }
}
