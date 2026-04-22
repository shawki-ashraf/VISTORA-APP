import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import 'package:mira_fashon/features/cart/cubit/cart_cubit.dart';
import 'package:mira_fashon/features/cart/view/checkview.dart';
import 'package:mira_fashon/features/cart/widgets/carditem.dart';
import 'package:mira_fashon/features/shared_widgets/custombottom.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.88);

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().startListeningToCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f7),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("My Cart", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),

      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartFailure) {
            return Center(child: Text(state.errorMessage));
          }

          if (state is CartLoaded) {
            final items = state.items;

            double total = items.fold(0, (sum, item) => sum + item.price);

            return Column(
              children: [
                /// 🧩 SWIPER
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text("Cart is empty"))
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: items.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return AnimatedScale(
                              duration: const Duration(milliseconds: 250),
                              scale: currentIndex == index ? 1 : 0.9,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: Carditem(
                                  name: item.name,
                                  image: item.image[3],
                                  price: item.price,
                                  quantity: item.quantity,
                                  size: item.size,
                                  onDelete: () {
                                    context.read<CartCubit>().removeFromCart(
                                      item.id,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),

                Gap(5.h),

                /// 🔘 DOTS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(items.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: currentIndex == index ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: currentIndex == index
                            ? Colors.black
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }),
                ),

                SizedBox(height: 10.h),

                /// 💰 SUMMARY SECTION
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 5.h,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${items.length} items",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "${total.toStringAsFixed(0)} EGP",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      SizedBox(height: 5.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Shipping"),
                          Text("Free", style: TextStyle(color: Colors.green)),
                        ],
                      ),

                      Divider(color: Colors.grey.shade300),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${total.toStringAsFixed(0)} EGP",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10.h),

                      /// 🚨 BUTTON WITH CONDITION
                      Custombottom(
                        text: items.isEmpty ? "Cart is Empty" : "Buy Now",

                        ontap: items.isEmpty
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<CartCubit>(),
                                      child: CheckoutScreen(
                                        cartItems: items,
                                        totalPrice: total,
                                        userId: items.first.id,
                                      ),
                                    ),
                                  ),
                                );
                              },
                      ),

                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
