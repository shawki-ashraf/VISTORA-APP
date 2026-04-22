import 'package:mira_fashon/core/paymob/paymom_mrthode.dart';

class PaymobRepository {
  final PaymobService service;

  PaymobRepository(this.service);

  Future<String> getPaymentKey({
    required int amount,
    required String currency,
    required String integrationId,
  }) async {
    try {
      // 1. Auth Token
      final authToken = await service.getAuthToken();

      // 2. Order
      final orderId = await service.createOrder(
        authToken: authToken,
        amountCents: (amount * 100).toString(),
        currency: currency,
      );

      // 3. Payment Key
      final paymentKey = await service.getPaymentKey(
        authToken: authToken,
        orderId: orderId,
        amount: amount,
        currency: currency,
        integrationId: integrationId,
      );

      return paymentKey;
    } catch (e) {
      throw Exception("Paymob Repository Error: $e");
    }
  }
}
