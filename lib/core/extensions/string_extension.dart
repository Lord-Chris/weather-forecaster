extension StringExtension on String {
  /// Capitalizes the first letter of the string.
  String capitalizeString() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
