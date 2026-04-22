import 'package:mira_fashon/core/firebase_service.dart';
import 'package:mira_fashon/features/profile/data/profiledata_model.dart';

class ProfiledataRepo {
  final FirebaseService _firebaseService = FirebaseService();

  Future<UserprofileModel?> getUserProfileData(String uid) async {
    return await _firebaseService.getUserData(uid);
  }

  Future<void> updateUserProfileData(
    String uid,
    UserprofileModel updatedProfile,
  ) async {
    await _firebaseService.updateUserData(
      uid: uid,
      data: updatedProfile.toMap(),
    );
  }
}
