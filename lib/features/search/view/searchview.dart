import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/searchbar.dart';
import '../../productsdetalies/view/productsdetalies.dart';

class SearchProductsScreen extends StatefulWidget {
  const SearchProductsScreen({super.key});

  @override
  State<SearchProductsScreen> createState() => _SearchProductsScreenState();
}

class _SearchProductsScreenState extends State<SearchProductsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SearchCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔍 Search Bar
            SearchView(
              onchanged: (value) {
                context.read<SearchCubit>().search(value);
              },
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(color: Colors.grey.shade300, height: 1),
            ),

            /// 📦 Results
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SearchEmpty) {
                    return Center(
                      child: Text(
                        "No products found",
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    );
                  }

                  if (state is SearchLoaded) {
                    return ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        final product = state.products[index];

                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductsDetails(
                                    image: product.images,
                                    id: product.id,
                                    name: product.name,
                                    category: product.category,
                                    description: product.description,
                                    price: product.price,
                                    rating: product.rating,
                                    sizes: product.sizes,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  /// 🖼 IMAGE (Fashion Style)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: Image.network(
                                      product.images[3],
                                      width: 90.w,
                                      height: 110.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  SizedBox(width: 12.w),

                                  /// 📄 INFO
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),

                                        SizedBox(height: 6.h),

                                        Text(
                                          product.category,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey,
                                          ),
                                        ),

                                        SizedBox(height: 10.h),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${product.price} EGP",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),

                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 14.sp,
                                                  color: Colors.amber,
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  "${product.rating}",
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
