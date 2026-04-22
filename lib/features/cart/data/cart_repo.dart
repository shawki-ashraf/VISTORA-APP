import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mira_fashon/core/checkout.dart';
import 'package:mira_fashon/core/firebase_service.dart';
import 'package:mira_fashon/features/cart/data/cartmodel.dart';

class CartRepo {
  final FirebaseService _firebaseService = FirebaseService();
  final OrderService _orderService = OrderService(FirebaseFirestore.instance);

  Future<void> addToCart(CartItemModel item) async {
    await _firebaseService.addToCart(item);
  }

  Stream<List<CartItemModel>> getCartItems() {
    return _firebaseService.getCartItemsStream();
  }

  Future<void> removeFromCart(String itemId) async {
    await _firebaseService.deleteCartItem(itemId);
  }

  Future<void> checkout(
    List<CartItemModel> cartItems,
    String userId,
    String paymentMethod,
  ) async {
    final user = _firebaseService.currentUserId;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    await OrderService(FirebaseFirestore.instance).checkout(
      userId: user,
      cartItems: cartItems,
      paymentMethod: paymentMethod,
    );
  }
}
