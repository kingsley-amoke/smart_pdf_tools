String formatFileSize(int bytes, {int decimals = 0}) {
  if (bytes <= 0) return '0 B';

  const kb = 1024;
  const mb = kb * 1024;
  const gb = mb * 1024;

  if (bytes >= gb) {
    return '${(bytes / gb).toStringAsFixed(decimals)} GB';
  } else if (bytes >= mb) {
    return '${(bytes / mb).toStringAsFixed(decimals)} MB';
  } else if (bytes >= kb) {
    return '${(bytes / kb).toStringAsFixed(decimals)} KB';
  } else {
    return '$bytes B';
  }
}
