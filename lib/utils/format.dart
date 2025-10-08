class Format {
  static String getTimeDifference(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hr';
    } else {
      return '${difference.inDays} day';
    }
  }

  static String getCountNumber(int count) {
    if (count / 1000 < 1) {
      return count.toString();
    } else if (count / 1000000 < 1) {
      double result = count / 1000;
      return "${result.toStringAsFixed(2)}K";
    } else {
      double result = count / 1000000;
      return "${result.toStringAsFixed(2)}M";
    }
  }
}
