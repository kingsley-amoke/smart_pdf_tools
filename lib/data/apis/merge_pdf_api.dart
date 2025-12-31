import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:smart_pdf_tools/core/utils/create_app_folder.dart';
import 'package:smart_pdf_tools/domain/usecases/merge.dart';

Timer? progressTimer;
bool uploadComplete = false;

class MergePdfApi extends MergePdf {
  final Dio dio;
  final List<File> files;
  final Function(double) onProgress;

  MergePdfApi({
    required this.dio,
    required this.files,
    required this.onProgress,
  });

  Future<String> call() async {
    try {
      // Prepare form data with multiple files
      List<MultipartFile> filesList = [];
      for (var file in files) {
        String fileName = file.path.split('/').last;
        filesList.add(
          await MultipartFile.fromFile(file.path, filename: fileName),
        );
      }


      FormData formData = FormData.fromMap({'files': filesList});

      // Get save directory
      final directory = await createAppFolder();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = '$directory/merged_$timestamp.pdf';

      // Start fake progress after upload completes
      void startFakeProgress() {
        double currentProgress = 0.2;
        progressTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
          if (currentProgress < 0.95) {
            currentProgress += 0.05;
            onProgress(currentProgress);
          } else {
            timer.cancel();
          }
        });
      }

      // Upload and download
      await dio
          .post(
            '/pdf/merge',
            data: formData,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ),
            onSendProgress: (sent, total) {
              // Upload progress (0 to 0.5)
              final progress = sent / total * 0.5;
              onProgress(progress);
              if (sent == total && !uploadComplete) {
                uploadComplete = true;
                startFakeProgress();
              }
            },
            onReceiveProgress: (received, total) {
              if (total != -1) {
                // Download progress (0.5 to 1.0)
                final progress = 0.5 + (received / total * 0.5);
                onProgress(progress);
              }
            },
          )
          .then((response) async {
            if (response.statusCode == 200 || response.statusCode == 201) {
              // Save file to phone
              final file = File(savePath);
              await file.writeAsBytes(response.data);
            } else {
              throw Exception('Server returned status: ${response.statusCode}');
            }
          });
      progressTimer?.cancel();
      onProgress(1.0);
      return savePath;
    } on DioException catch (e) {
      if (e.response != null) {}
      progressTimer?.cancel();
      throw Exception('Failed to merge PDFs: ${e.message}');
    } catch (e) {
      progressTimer?.cancel();
      throw Exception('Failed to merge PDFs: $e');
    }
  }
}
