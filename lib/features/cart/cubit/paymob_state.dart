abstract class PaymobState {}

class PaymobInitial extends PaymobState {}

class PaymobLoading extends PaymobState {}

class PaymobSuccess extends PaymobState {
  final String paymentKey;

  PaymobSuccess(this.paymentKey);
}

class PaymobError extends PaymobState {
  final String error;

  PaymobError(this.error);
}
