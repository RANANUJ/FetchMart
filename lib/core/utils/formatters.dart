abstract final class Formatters {
  static String currency(num value) => '\$${value.toStringAsFixed(2)}';

  static String compactCurrency(num value) {
    final text = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    return '\$$text';
  }

  static String categoryName(String value) {
    return value
        .split(RegExp(r'[-_\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}
