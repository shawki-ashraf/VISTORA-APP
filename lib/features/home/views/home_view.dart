import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mira_fashon/features/favorite/cubit/favorite_cubit.dart';

import 'package:mira_fashon/features/home/cubit/products_cubit.dart';
import 'package:mira_fashon/features/home/widgets/customcatodry.dart';
import 'package:mira_fashon/features/home/widgets/customgrid.dart';
import 'package:mira_fashon/features/productsdetalies/view/productsdetalies.dart';
import 'package:mira_fashon/features/shared_widgets/customtext.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final List<Map<String, dynamic>> categories = [
    {'label': 'T-Shirt', 'icon': 'assets/shirt.svg', 'isSelected': true},
    {'label': 'Pants', 'icon': 'assets/pants.svg', 'isSelected': false},
    {'label': 'Dresses', 'icon': 'assets/dress.svg', 'isSelected': false},
    {'label': 'All Items', 'icon': 'assets/items.svg', 'isSelected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset("assets/v.png", height: 30.h, width: 100.w),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.shopping_bag_outlined, color: Colors.black),
          ),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Gap(10.h)),

          /// 🔥 BANNER (NEW DESIGN LIKE IMAGE)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Stack(
                  children: [
                    Image.network(
                      "https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                      height: 200.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    Container(
                      height: 200.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.45),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                    ),

                    Positioned(
                      left: 16,
                      top: 35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "20% OFF",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Gap(6.h),
                          Text(
                            "For selected spring styles",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                          Gap(12.h),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Shop Now"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: Gap(20.h)),

          /// 🔹 CATEGORIES
          SliverToBoxAdapter(
            child: SizedBox(
              height: 60.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryChip(
                    label: category['label'],
                    iconPath: category['icon'],
                    isSelected: category['isSelected'],
                    onTap: () {
                      setState(() {
                        for (var c in categories) {
                          c['isSelected'] = false;
                        }
                        category['isSelected'] = true;
                      });
                    },
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(child: Gap(5.h)),

          /// 🔥 DESIGNER COLLECTION HEADER
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Customtext(
                    text: "Designer Collection",
                    size: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  TextButton(onPressed: () {}, child: const Text("See all")),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: Gap(10.h)),

          /// 🔥 PRODUCTS GRID
          BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) {
              if (state is ProductsLoaded) {
                final products = state.products;

                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return GridProductsModern(
                        name: products[index].name,
                        image: products[index].images.isNotEmpty
                            ? products[index].images[0]
                            : 'https://via.placeholder.com/150',
                        rate: products[index].rating,
                        category: products[index].category,
                        price: products[index].price,
                        isFavorite: context.read<FavoriteCubit>().isFavorite(
                          products[index].id,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductsDetails(
                                image: products[index].images,
                                name: products[index].name,
                                category: products[index].category,
                                price: products[index].price,
                                rating: products[index].rating,
                                description: products[index].description,
                                sizes: products[index].sizes,
                                id: products[index].id,
                                discount: products[index].discount,
                              ),
                            ),
                          );
                        },
                        onFavoriteToggle: () {
                          context.read<FavoriteCubit>().toggleFavorite(
                            products[index].id,
                          );
                        },
                      );
                    }, childCount: products.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 14.h,
                      childAspectRatio: 0.55,
                    ),
                  ),
                );
              }
              if (state is ProductsLoading) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Skeletonizer(
                          enabled: true,
                          child: GridProductsModern(
                            name: "Loading...",
                            image: '',
                            rate: 0,
                            category: "Loading",
                            price: 0,
                            isFavorite: false,
                            onTap: () {},
                            onFavoriteToggle: () {},
                          ),
                        );
                      },
                      childCount: 6, // عدد العناصر الوهمية
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 14.h,
                      childAspectRatio: 0.55,
                    ),
                  ),
                );
              }

              if (state is ProductsError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text(state.message)),
                );
              }

              return const SliverToBoxAdapter(
                child: Center(child: Text("No products found")),
              );
            },
          ),

          SliverToBoxAdapter(child: Gap(20.h)),
        ],
      ),
    );
  }
}
