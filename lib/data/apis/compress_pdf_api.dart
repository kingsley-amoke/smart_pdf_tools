import 'dart:io';

import 'package:dio/dio.dart';
import 'package:smart_pdf_tools/core/utils/create_app_folder.dart';
import 'package:smart_pdf_tools/domain/models/compression_quality.dart';
import 'package:smart_pdf_tools/domain/usecases/compress_pdf.dart';

class CompressPdfApi extends CompressPdf {
  final Dio dio;
  final File file;
  final CompressionQuality quality;
  final bool compressImages;
  final bool removeMetadata;
  final Function(double) onProgress;

  CompressPdfApi({
    required this.dio,
    required this.file,
    required this.quality,
    required this.onProgress,
    this.compressImages = true,
    this.removeMetadata = true,
  });

  Future<Map<String, dynamic>> call() async {
    try {
      // Prepare form data
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'quality': quality.name,
        'compressImages': compressImages,
        'removeMetadata': removeMetadata,
      });

      // Get save directory
      final directory = await createAppFolder();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = '$directory/compressed_$timestamp.pdf';

      int? compressedSize;
      String? reductionPercentage;

      // Upload and download
      await dio
          .post(
            '/pdf/compress',
            data: formData,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ),
            onSendProgress: (sent, total) {
              final progress = sent / total * 0.5;
              onProgress(progress);
              print('⬆️  Upload: ${(progress * 100).toInt()}%');
            },
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = 0.5 + (received / total * 0.5);
                onProgress(progress);
                print('⬇️  Download: ${(progress * 100).toInt()}%');
              }
            },
          )
          .then((response) async {
            if (response.statusCode == 200 || response.statusCode == 201) {
              // Get compression stats from headers
              compressedSize = int.tryParse(
                response.headers.value('x-compressed-size') ?? '0',
              );
              reductionPercentage = response.headers.value(
                'x-reduction-percentage',
              );

              // Save file
              final resultFile = File(savePath);
              await resultFile.writeAsBytes(response.data);
              print('✅ File saved successfully');
            } else {
              throw Exception('Server returned status: ${response.statusCode}');
            }
          });

      return {
        'filePath': savePath,
        'compressedSize': compressedSize,
        'reductionPercentage': reductionPercentage,
      };
    } on DioException catch (e) {
      throw Exception('Failed to compress PDF: ${e.message}');
    } catch (e) {
      throw Exception('Failed to compress PDF: $e');
    }
  }
}
