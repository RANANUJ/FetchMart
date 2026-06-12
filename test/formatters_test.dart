import 'package:fetchmart/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats category slugs into readable names', () {
    expect(Formatters.categoryName('mens-shirts'), 'Mens Shirts');
  });
}
