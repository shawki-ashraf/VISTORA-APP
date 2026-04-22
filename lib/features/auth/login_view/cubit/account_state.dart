part of 'account_cubit.dart';

@immutable
sealed class AccountState {}

final class AccountInitial extends AccountState {}

final class AccountLoading extends AccountState {}

final class AccountSuccess extends AccountState {
  final UserModel user;
  AccountSuccess(this.user);
}

final class AccountLoggedOut extends AccountState {}

final class AccountFailure extends AccountState {
  final String error;
  AccountFailure(this.error);
}
