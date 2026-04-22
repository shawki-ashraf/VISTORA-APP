import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mira_fashon/features/home/data/products_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// جلب كل المنتجات مرة واحدة
  Future<List<ProductModel>> getAllProducts() async {
    final snapshot = await _firestore.collection('mira_products').get();

    return snapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Search محلي (case insensitive)
  List<ProductModel> searchProducts(List<ProductModel> products, String query) {
    final lowerQuery = query.toLowerCase();

    return products.where((product) {
      final name = product.name.toLowerCase();
      return name.contains(lowerQuery);
    }).toList();
  }
}
