import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:smart_pdf_tools/core/adapters/split_method_adapter.dart';
import 'package:smart_pdf_tools/core/utils/create_app_folder.dart';
import 'package:smart_pdf_tools/domain/models/split_method.dart';
import 'package:smart_pdf_tools/domain/usecases/split_pdf.dart';

Timer? progressTimer;
bool uploadComplete = false;

class SplitPdfApi extends SplitPdf {
  SplitPdfApi({
    required this.dio,
    required this.file,
    required this.method,
    required this.onProgress,
    required this.pagesPerSplit,
    required this.ranges,
  });

  final Dio dio;
  final File file;
  final SplitMethod method;
  final String? ranges;
  final int? pagesPerSplit;
  final Function(double) onProgress;

  Future<String> call() async {
    final splitMethodAdapter = SplitMethodAdapter(method: method);
    try {
      // Prepare form data
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'method': splitMethodAdapter.toApiString(),
        if (ranges != null) 'ranges': ranges,
        if (pagesPerSplit != null) 'pagesPerSplit': pagesPerSplit,
      });

      // Get save directory
      final directory = await createAppFolder();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = '$directory/split_$timestamp.zip';

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
            '/pdf/split',
            data: formData,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ),
            onSendProgress: (sent, total) {
              final progress = sent / total * 0.5;
              onProgress(progress);
              if (sent == total && !uploadComplete) {
                uploadComplete = true;
                startFakeProgress();
              }
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
              // Save ZIP file
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
      progressTimer?.cancel();
      throw Exception('Failed to split PDF: ${e.message}');
    } catch (e) {
      progressTimer?.cancel();
      throw Exception('Failed to split PDF: $e');
    }
  }
}
