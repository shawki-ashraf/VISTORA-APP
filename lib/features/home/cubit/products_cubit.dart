import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mira_fashon/features/home/data/products_model.dart';
import 'package:mira_fashon/features/home/data/products_repo.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductsRepo _repo = ProductsRepo();

  StreamSubscription? _subscription;

  ProductsCubit() : super(ProductsInitial());

  void fetchProducts() {
    emit(ProductsLoading());

    _subscription?.cancel(); // مهم لو اتعمل reload

    _subscription = _repo.getProducts().listen(
      (products) {
        emit(ProductsLoaded(products));
      },
      onError: (error) {
        print("🔥 ERROR: $error");
        emit(ProductsError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
