import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mira_fashon/features/cart/data/cartmodel.dart';
import 'package:mira_fashon/features/profile/data/profiledata_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= SAFE USER =================

  String? get currentUserId => _auth.currentUser?.uid;

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  void _requireUser() {
    if (_auth.currentUser == null) {
      throw Exception("User not logged in");
    }
  }

  // ================= AUTH =================

  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ================= PROFILE =================

  Future<void> createUserData({
    required String uid,
    required String email,
    required String username,
  }) async {
    try {
      final data = {
        "username": username,
        "email": email,
        "imageUrl": "",
        "createdAt": FieldValue.serverTimestamp(),
      };

      await _firestore.collection('Mira Users').doc(uid).set(data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserprofileModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('Mira Users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserprofileModel.fromMap(doc.data()!);
  }

  Future<void> updateUserData({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('Mira Users').doc(uid).update(data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ================= GENERIC FIRESTORE =================

  Future<void> addData({
    required String collection,
    required Map<String, dynamic> data,
    String? docId,
  }) async {
    try {
      if (docId != null) {
        await _firestore.collection(collection).doc(docId).set(data);
      } else {
        await _firestore.collection(collection).add(data);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<QueryDocumentSnapshot>> getData({
    required String collection,
  }) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      return snapshot.docs;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateData({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ================= CART (SAFE VERSION) =================

  Stream<List<CartItemModel>> getCartItemsStream() {
    final uid = currentUserId;

    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('Mira Users')
        .doc(uid)
        .collection('cart_products')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CartItemModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addToCart(CartItemModel item) async {
    _requireUser();
    final uid = currentUserId!;

    final docRef = _firestore
        .collection('Mira Users')
        .doc(uid)
        .collection('cart_products')
        .doc(item.id);

    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.update({'quantity': FieldValue.increment(1)});
    } else {
      await docRef.set(item.toJson());
    }
  }

  Future<void> deleteCartItem(String id) async {
    _requireUser();
    final uid = currentUserId!;

    await _firestore
        .collection('Mira Users')
        .doc(uid)
        .collection('cart_products')
        .doc(id)
        .delete();
  }

  Future<void> decreaseQuantity(String id, int currentQty) async {
    _requireUser();
    final uid = currentUserId!;

    final docRef = _firestore
        .collection('Mira Users')
        .doc(uid)
        .collection('cart_products')
        .doc(id);

    if (currentQty <= 1) {
      await docRef.delete();
    } else {
      await docRef.update({'quantity': FieldValue.increment(-1)});
    }
  }

  Future<void> clearCart() async {
    _requireUser();
    final uid = currentUserId!;

    final snapshot = await _firestore
        .collection('Mira Users')
        .doc(uid)
        .collection('cart_products')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
