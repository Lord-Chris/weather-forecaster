extension StringExtension on String {
  String capitalizeString() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
