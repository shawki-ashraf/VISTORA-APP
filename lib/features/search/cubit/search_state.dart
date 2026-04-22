import 'package:mira_fashon/features/home/data/products_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<ProductModel> products;

  SearchLoaded(this.products);
}

class SearchEmpty extends SearchState {}
