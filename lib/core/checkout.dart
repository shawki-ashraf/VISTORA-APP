import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mira_fashon/features/cart/data/cartmodel.dart';

class OrderService {
  final FirebaseFirestore firestore;

  OrderService(this.firestore);

  Future<void> checkout({
    required String userId,
    required List<CartItemModel> cartItems,
    required String paymentMethod,
  }) async {
    final batch = firestore.batch();

    // 🧾 1. حساب الإجمالي
    double totalPrice = 0;
    for (var item in cartItems) {
      totalPrice += item.price * item.quantity;
    }

    // 🔄 2. تحويل لـ OrderItems
    final orderItems = cartItems
        .map((item) => OrderItemModel.fromCart(item).toJson())
        .toList();

    // 📦 3. إنشاء order doc
    final orderRef = firestore.collection('orders').doc();

    batch.set(orderRef, {
      'userId': userId,
      'items': orderItems,
      'totalPrice': totalPrice,
      'status': 'pending',
      'createdAt': Timestamp.now(),
      'paymentMethod': paymentMethod,
    });

    // 🗑️ 4. مسح الكارت
    final cartRef = firestore
        .collection('users')
        .doc(userId)
        .collection('cart');

    final cartSnapshot = await cartRef.get();

    for (var doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 🚀 5. تنفيذ كل ده مرة واحدة
    await batch.commit();
  }
}
