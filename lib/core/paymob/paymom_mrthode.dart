import 'package:mira_fashon/core/apisrevice.dart';
import 'package:mira_fashon/core/constant.dart';

class PaymobService {
  final ApiService apiService = ApiService();

  Future<String> getAuthToken() async {
    final response = await ApiService.post(
      endpoint: "/auth/tokens",
      data: {"api_key": PaymobConstants.apiKey},
      ApiKey: PaymobConstants.apiKey,
    );

    return response.data['token'];
  }

  Future<int> createOrder({
    required String authToken,
    required String amountCents,
    required String currency,
  }) async {
    final response = await ApiService.post(
      endpoint: "/ecommerce/orders",
      data: {
        "auth_token": authToken,
        "delivery_needed": "false",
        "amount_cents": amountCents,
        "currency": currency,
        "items": [],
      },
      ApiKey: PaymobConstants.apiKey,
    );

    return response.data['id'];
  }

  Future<String> getPaymentKey({
    required String authToken,
    required int orderId,
    required int amount,
    required String currency,
    required String integrationId,
  }) async {
    final response = await ApiService.post(
      endpoint: "/acceptance/payment_keys",
      data: {
        "auth_token": authToken,
        "amount_cents": (amount * 100).toString(),
        "expiration": 3600,
        "order_id": orderId,
        "currency": currency,
        "integration_id": integrationId,
        "billing_data": {
          "first_name": "test",
          "last_name": "user",
          "email": "test@test.com",
          "phone_number": "01000000000",
          "country": "EG",
          "city": "Cairo",
          "street": "NA",
          "building": "NA",
          "floor": "NA",
          "apartment": "NA",
        },
      },
      ApiKey: PaymobConstants.apiKey,
    );

    return response.data['token'];
  }
}
