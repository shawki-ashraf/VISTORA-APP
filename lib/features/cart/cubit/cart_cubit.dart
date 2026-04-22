import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mira_fashon/core/firebase_service.dart';
import 'package:mira_fashon/features/cart/data/cart_repo.dart';
import 'package:mira_fashon/features/cart/data/cartmodel.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepo _cartRepo = CartRepo();
  final FirebaseService _firebaseService = FirebaseService();
  CartCubit() : super(CartInitial());

  StreamSubscription? _subscription;

  /// ✅ إضافة بدون Loading
  Future<void> addToCart(CartItemModel item) async {
    try {
      emit(CartLoading());
      await _cartRepo.addToCart(item);
      emit(
        CartLoaded([]),
      ); // Emit a loaded state with an empty list or the updated cart items
    } catch (e) {
      emit(CartFailure(e.toString()));
    }
  }

  /// ✅ الاستماع للـ Firebase
  void startListeningToCart() {
    emit(CartLoading());

    _subscription = _cartRepo.getCartItems().listen(
      (items) {
        print("🔥🔥 ITEMS: ${items.length}");
        emit(CartLoaded(items));
      },
      onError: (error) {
        print("❌ ERROR: $error");
        emit(CartFailure(error.toString()));
      },
    );
  }

  void stopListeningToCart() {
    _subscription?.cancel();
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      await _cartRepo.removeFromCart(itemId);
    } catch (e) {
      emit(CartFailure(e.toString()));
    }
  }

  Future<void> checkout(
    List<CartItemModel> cartItems,
    String userId,
    String paymentMethod,
  ) async {
    try {
      emit(CartLoading());
      await _cartRepo.checkout(cartItems, userId, paymentMethod);
      await _firebaseService
          .clearCart(); // Clear cart in Firebase after successful checkout

      // Clear cart after successful checkout
    } catch (e) {
      emit(CartFailure(e.toString()));
    }
  }
}
