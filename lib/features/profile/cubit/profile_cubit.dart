import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mira_fashon/features/profile/data/profiledata_model.dart';
import 'package:mira_fashon/features/profile/data/profiledata_repo.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfiledataRepo _repo = ProfiledataRepo();

  ProfileCubit() : super(ProfileInitial());

  Future<void> loadUserProfile() async {
    emit(ProfileLoading());

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      emit(ProfileError("No authenticated user"));
      return;
    }

    try {
      final profile = await _repo.getUserProfileData(user.uid);

      if (profile == null) {
        emit(ProfileError("User not found in Firestore"));
        return;
      }

      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({
    required String username,
    required String imageUrl,
  }) async {
    emit(ProfileLoading());

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      emit(ProfileError("No authenticated user"));
      return;
    }

    try {
      final updatedProfile = UserprofileModel(
        username: username,
        imageUrl: imageUrl,
        email: user.email ?? '',
        createdAt: DateTime.now(),
      );

      await _repo.updateUserProfileData(user.uid, updatedProfile);
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
