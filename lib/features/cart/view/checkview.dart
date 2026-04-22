import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mira_fashon/features/cart/cubit/cart_cubit.dart';
import 'package:mira_fashon/features/cart/data/cartmodel.dart';
import 'package:mira_fashon/roote.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final String userId;
  final double totalPrice;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.userId,
    required this.totalPrice,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String paymentMethod = "cash";

  bool isLoading = false;

  final TextEditingController cardNumber = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController expiry = TextEditingController();
  final TextEditingController cvv = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Checkout", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          /// 🔥 الصفحة الأساسية
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// 🔥 Order Summary
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Order Summary",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _RowItem("Subtotal", "${widget.totalPrice} EGP"),
                    _RowItem("Shipping", "Free"),
                    const Divider(),
                    _RowItem("Total", "${widget.totalPrice} EGP", isBold: true),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 Payment Methods
              paymentOption(
                title: "Cash on Delivery",
                imagePath: "assets/payment-method.png",
                selected: paymentMethod == "cash",
                onTap: () => setState(() => paymentMethod = "cash"),
              ),
              paymentOption(
                title: "Credit Card",
                imagePath: "assets/debit-card.png",
                selected: paymentMethod == "visa",
                onTap: () => setState(() => paymentMethod = "visa"),
              ),

              const SizedBox(height: 20),

              /// 🔥 Credit Card Form
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: paymentMethod == "visa"
                    ? _card(child: creditCardForm())
                    : const SizedBox(),
              ),

              const SizedBox(height: 30),

              /// 🔥 Confirm Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);

                        try {
                          await context.read<CartCubit>().checkout(
                            widget.cartItems,
                            widget.userId,
                            paymentMethod,
                          );

                          /// ✅ Success SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              content: Row(
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text("Order placed successfully"),
                                ],
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          /// ⏳ انتظار قبل الانتقال
                          await Future.delayed(const Duration(seconds: 2));

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomBottomNav(),
                            ),
                            (route) => false,
                          );
                        } catch (e) {
                          /// ❌ Error SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              content: Row(
                                children: const [
                                  Icon(Icons.error, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text("Something went wrong"),
                                ],
                              ),
                            ),
                          );
                        }

                        setState(() => isLoading = false);
                      },
                child: const Text(
                  "Confirm Payment",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),

          /// 🔥 Loading Overlay (Lottie)
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset("assets/Loading Dots.json", width: 120),
                    const SizedBox(height: 10),
                    const Text(
                      "Processing...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 🔹 Card UI
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  /// 🔹 Payment Option
  Widget paymentOption({
    required String title,
    required String imagePath,
    required bool selected,
    required VoidCallback onTap,
    bool isNetworkImage = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? Colors.black.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Image.asset(imagePath, width: 28, height: 28),

            const SizedBox(width: 10),

            Expanded(
              child: Center(
                child: Text(title, style: const TextStyle(fontSize: 16)),
              ),
            ),

            if (selected) const Icon(Icons.check_circle, color: Colors.black),
          ],
        ),
      ),
    );
  }

  /// 🔥 Credit Card Form
  Widget creditCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Card Details",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        _modernInput(
          hint: "1234 5678 9012 3456",
          label: "Card Number",
          icon: Icons.credit_card,
          controller: cardNumber,
        ),

        _modernInput(
          hint: "Shawki Ashraf",
          label: "Card Holder",
          icon: Icons.person,
          controller: name,
        ),

        Row(
          children: [
            Expanded(
              child: _modernInput(
                hint: "MM/YY",
                label: "Expiry",
                icon: Icons.calendar_month,
                controller: expiry,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _modernInput(
                hint: "123",
                label: "CVV",
                icon: Icons.lock,
                controller: cvv,
                isPassword: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 🔥 Modern Input
  Widget _modernInput({
    required String hint,
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 Row Item
class _RowItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;

  const _RowItem(this.title, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
