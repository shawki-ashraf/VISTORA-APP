import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addToFavorite(String productId) async {
    final userId = _auth.currentUser!.uid;

    await _firestore
        .collection("Mira Users")
        .doc(userId)
        .collection("favorites")
        .doc(productId)
        .set({"createdAt": FieldValue.serverTimestamp()});
  }

  Future<void> removeFromFavorite(String productId) async {
    final userId = _auth.currentUser!.uid;

    await _firestore
        .collection("Mira Users")
        .doc(userId)
        .collection("favorites")
        .doc(productId)
        .delete();
  }

  Stream<List<String>> getFavorites() {
    final userId = _auth.currentUser!.uid;

    return _firestore
        .collection("Mira Users")
        .doc(userId)
        .collection("favorites")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((e) => e.id).toList());
  }
}
