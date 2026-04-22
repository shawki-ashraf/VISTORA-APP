import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mira_fashon/features/cart/data/paymob.dart';
import 'paymob_state.dart';

class PaymobCubit extends Cubit<PaymobState> {
  final PaymobRepository repository;

  PaymobCubit(this.repository) : super(PaymobInitial());

  Future<void> getPaymentKey({
    required int amount,
    required String currency,
    required String integrationId,
  }) async {
    try {
      emit(PaymobLoading());

      final paymentKey = await repository.getPaymentKey(
        amount: amount,
        currency: currency,
        integrationId: integrationId,
      );

      emit(PaymobSuccess(paymentKey));
    } catch (e) {
      emit(PaymobError(e.toString()));
    }
  }
}
