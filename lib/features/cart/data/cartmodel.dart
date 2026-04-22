class CartItemModel {
  final String id;
  final String name;
  final List<String> image;
  final double price;
  final int quantity;
  final String size;

  CartItemModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.quantity = 1,
    required this.size,
  });

  /// 🔄 fromJson
  factory CartItemModel.fromJson(Map<String, dynamic> json, String docId) {
    return CartItemModel(
      id: docId, // ✅ ناخد ID من Firestore
      name: json['name'] ?? '',

      /// ✅ الحل هنا
      image: json['image'] is List
          ? (json['image'] as List).map((e) => e.toString()).toList()
          : [json['image'].toString()],

      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] ?? 1),
      size: json['size'] ?? '',
    );
  }

  /// 📤 toJson
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
      'size': size,
    };
  }
}

class OrderItemModel {
  final String productId;
  final String name;
  final List<String> image;
  final double price;
  final int quantity;
  final String size;
  final String paymentMethod;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.size,
    required this.paymentMethod,
  });

  /// 🔄 تحويل من CartItemModel
  factory OrderItemModel.fromCart(CartItemModel cartItem) {
    return OrderItemModel(
      productId: cartItem.id,
      name: cartItem.name,
      image: cartItem.image,
      price: cartItem.price,
      quantity: cartItem.quantity,
      size: cartItem.size, paymentMethod: 'cash',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
      'size': size,
    };
  }
}
