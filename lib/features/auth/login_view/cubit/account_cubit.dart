import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:mira_fashon/features/auth/login_view/data/user_repo.dart';
import 'package:mira_fashon/features/auth/login_view/data/usermodel.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final UserRepo _userRepo = UserRepo();

  AccountCubit() : super(AccountInitial());

  /// 🆕 SAVE USER
  Future<void> _saveUserToFirestore(User user) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email,
      username: user.displayName,
    );

    await FirebaseFirestore.instance
        .collection('Mira Users')
        .doc(user.uid)
        .set(userModel.toMap(), SetOptions(merge: true));
  }

  /// 🔐 LOGIN
  Future<void> login({required String email, required String password}) async {
    emit(AccountLoading());
    try {
      final user = await _userRepo.login(email: email, password: password);

      if (user != null) {
        await _saveUserToFirestore(user);

        /// 🔥 نجيب username من Firestore (مش displayName)
        final doc = await FirebaseFirestore.instance
            .collection('Mira Users')
            .doc(user.uid)
            .get();

        final userModel = UserModel(
          uid: user.uid,
          email: user.email,
          username: doc.data()?['username'],
        );

        emit(AccountSuccess(userModel));
      } else {
        emit(AccountFailure("Login failed"));
      }
    } catch (e) {
      emit(AccountFailure("This account is not registered"));
    }
  }

  /// 🆕 REGISTER
  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    emit(AccountLoading());
    try {
      final user = await _userRepo.signUp(
        email: email,
        password: password,
        username: username,
      );

      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          username: username,
        );

        emit(AccountSuccess(userModel));
      } else {
        emit(AccountFailure("Registration failed"));
      }
    } catch (e) {
      emit(AccountFailure("This account is already registered"));
    }
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    emit(AccountLoading());
    try {
      await _userRepo.signOut();
      emit(AccountLoggedOut());
    } catch (e) {
      emit(AccountFailure("Logout failed"));
    }
  }
}
