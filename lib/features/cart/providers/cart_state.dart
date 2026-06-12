import '../domain/entities/cart_item.dart';

class CartState {
  const CartState({this.items = const <CartItem>[]});

  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  int get totalQuantity {
    return items.fold<int>(0, (total, item) => total + item.quantity);
  }

  double get totalPrice {
    return items.fold<double>(0, (total, item) => total + item.totalPrice);
  }

  int quantityFor(int productId) {
    for (final item in items) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }
}
