import '../../../products/data/models/product_model.dart';
import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required ProductModel super.product,
    required super.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(
        Map<String, dynamic>.from(json['product'] as Map),
      ),
      quantity: _asInt(json['quantity']).clamp(1, 99).toInt(),
    );
  }

  factory CartItemModel.fromEntity(CartItem item) {
    return CartItemModel(
      product: ProductModel.fromEntity(item.product),
      quantity: item.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': ProductModel.fromEntity(product).toJson(),
      'quantity': quantity,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 1;
  }
}
