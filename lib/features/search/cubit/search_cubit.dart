import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mira_fashon/features/home/data/products_model.dart';
import 'package:mira_fashon/features/search/data/search_repo.dart';

import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final ProductRepository repository = ProductRepository();

  SearchCubit() : super(SearchInitial());

  List<ProductModel> _allProducts = [];

  /// تحميل كل المنتجات مرة واحدة
  Future<void> loadProducts() async {
    emit(SearchLoading());

    try {
      _allProducts = await repository.getAllProducts();
      SearchLoaded(_allProducts.take(4).toList());

      emit(SearchLoaded(_allProducts));
    } catch (e) {
      emit(SearchEmpty());
    }
  }

  /// البحث المحلي
  void search(String query) {
    if (query.isEmpty) {
      emit(
        SearchLoaded(_allProducts.toList()),
      ); // عرض أول 4 منتجات عند عدم وجود بحث
      return;
    }

    final result = repository.searchProducts(_allProducts, query);

    if (result.isEmpty) {
      emit(SearchEmpty());
    } else {
      emit(SearchLoaded(result));
    }
  }
}
