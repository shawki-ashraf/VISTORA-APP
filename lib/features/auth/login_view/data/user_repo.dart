import 'package:firebase_auth/firebase_auth.dart';
import 'package:mira_fashon/core/firebase_service.dart';

class UserRepo {
  final FirebaseService _firebaseService = FirebaseService();

  /// 🔐 LOGIN
  Future<User?> login({required String email, required String password}) async {
    final user = await _firebaseService.signIn(
      email: email,
      password: password,
    );

    return user;
  }

  /// 🆕 SIGN UP + SAVE USER DATA
  Future<User?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final user = await _firebaseService.signUp(
      email: email,
      password: password,
    );

    if (user != null) {
      /// 🔥 مهم: تحديث displayName في FirebaseAuth
      await user.updateDisplayName(username);
      await user.reload();

      final updatedUser = FirebaseAuth.instance.currentUser!;

      /// 🔥 حفظ في Firestore
      await _firebaseService.createUserData(
        uid: updatedUser.uid,
        email: email,
        username: username,
      );

      return updatedUser;
    }

    return null;
  }

  /// 🚪 LOGOUT
  Future<void> signOut() async {
    await _firebaseService.signOut();
  }
}
