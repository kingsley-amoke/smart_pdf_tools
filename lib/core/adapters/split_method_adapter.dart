import 'package:smart_pdf_tools/presentation/view/pages/split.dart';

class SplitMethodAdapter {
  final SplitMethod method;

  const SplitMethodAdapter({required this.method});

  String toApiString() {
    switch (method) {
      case SplitMethod.ranges:
        return 'ranges';
      case SplitMethod.individual:
        return 'individual';
      case SplitMethod.everyN:
        return 'every_n';
    }
  }
}
