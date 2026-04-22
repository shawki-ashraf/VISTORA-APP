import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mira_fashon/features/auth/login_view/cubit/account_cubit.dart';
import 'package:mira_fashon/features/cart/cubit/cart_cubit.dart';
import 'package:mira_fashon/features/cart/view/cartview.dart';
import 'package:mira_fashon/features/favorite/cubit/favorite_cubit.dart';
import 'package:mira_fashon/features/favorite/view/favo.dart';
import 'package:mira_fashon/features/home/cubit/products_cubit.dart';
import 'package:mira_fashon/features/home/views/home_view.dart';
import 'package:mira_fashon/features/profile/cubit/profile_cubit.dart';
import 'package:mira_fashon/features/profile/view/profile.dart';
import 'package:mira_fashon/features/search/cubit/search_cubit.dart';
import 'package:mira_fashon/features/search/view/searchview.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int currentIndex = 0;

  final List<Widget> screens = [
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProductsCubit()..fetchProducts()),
        BlocProvider(create: (_) => FavoriteCubit()),
      ],
      child: HomeView(),
    ),
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => FavoriteCubit()..loadFavorites()),
        BlocProvider(create: (_) => ProductsCubit()..fetchProducts()),
      ],
      child: Favorite(),
    ),
    BlocProvider(
      create: (context) => SearchCubit(),
      child: SearchProductsScreen(),
    ),
    BlocProvider(
      create: (context) => CartCubit()..startListeningToCart(),
      child: CartScreen(),
    ),
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProfileCubit()..loadUserProfile()),
        BlocProvider(create: (context) => AccountCubit()),
      ],
      child: FashionProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),

      /// 🔥 UPDATED BOTTOM NAV UI ONLY
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isSelected = currentIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8B5E3C).withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: isSelected
                              ? const Color(0xFF8B5E3C)
                              : Colors.grey,
                        ),

                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: isSelected
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Text(
                                    item.label,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF8B5E3C),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}

const List<NavItem> _items = [
  NavItem(icon: Icons.home_rounded, label: "Home"),
  NavItem(icon: Icons.favorite_border, label: "Favorites"),
  NavItem(icon: Icons.search_rounded, label: "Search"),
  NavItem(icon: Icons.shopping_cart_outlined, label: "Cart"),
  NavItem(icon: Icons.person_outline, label: "Profile"),
];
