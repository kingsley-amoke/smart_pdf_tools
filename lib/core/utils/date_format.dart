String relativeDate(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inDays >= 7) return '${(d.inDays / 7).floor()}w ago';
  if (d.inDays >= 1) return '${d.inDays}d ago';
  if (d.inHours >= 1) return '${d.inHours}h ago';
  return 'just now';
}
