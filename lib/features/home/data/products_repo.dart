import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mira_fashon/features/home/data/products_model.dart';

class ProductsRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ProductModel>> getProducts() {
    return _firestore.collection('mira_products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }
}
