import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import 'package:mira_fashon/features/favorite/cubit/favorite_cubit.dart';
import 'package:mira_fashon/features/home/cubit/products_cubit.dart';
import 'package:mira_fashon/features/home/widgets/customgrid.dart';
import 'package:mira_fashon/features/shared_widgets/customtext.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  String getSafeImage(List<String> images) {
    if (images.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    return images.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Customtext(
          text: "My Favorites",
          size: 22.sp,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
      body: BlocBuilder<FavoriteCubit, FavoriteState>(
        builder: (context, favState) {
          final productsState = context.watch<ProductsCubit>().state;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: Gap(20.h)),

              if (favState is FavoriteLoading ||
                  productsState is ProductsLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (favState is FavoriteError)
                SliverFillRemaining(
                  child: Center(child: Text(favState.message)),
                )
              else if (favState is FavoriteLoaded &&
                  productsState is ProductsLoaded) ...[
                if (favState.favoriteProductIds.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text("No favorites yet!")),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final favoriteProducts = productsState.products
                              .where(
                                (product) => favState.favoriteProductIds
                                    .contains(product.id),
                              )
                              .toList();

                          final product = favoriteProducts[index];

                          return GridProductsModern(
                            name: product.name,
                            image: getSafeImage(product.images),
                            rate: product.rating,
                            category: product.category,
                            price: product.price,
                            isFavorite: true,
                            onTap: () {},
                            onFavoriteToggle: () {
                              context.read<FavoriteCubit>().toggleFavorite(
                                product.id,
                              );
                            },
                          );
                        },
                        childCount: productsState.products
                            .where(
                              (product) => favState.favoriteProductIds.contains(
                                product.id,
                              ),
                            )
                            .length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 14.h,
                        childAspectRatio: 0.55,
                      ),
                    ),
                  ),
              ] else
                const SliverFillRemaining(
                  child: Center(child: Text("No favorites yet!")),
                ),
            ],
          );
        },
      ),
    );
  }
}
