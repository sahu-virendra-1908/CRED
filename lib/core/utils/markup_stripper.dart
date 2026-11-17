abstract final class MarkupStripper {
  static final RegExp _tagRegex = RegExp(r'<[^>]*>');

  /// Strips CRED SDUI markup tags such as `<format>₹9,67,340</format>`.
  static String strip(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return raw.replaceAll(_tagRegex, '').trim();
  }
}
