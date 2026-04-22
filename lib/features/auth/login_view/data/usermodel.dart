class UserModel {
  final String uid;
  final String? email;
  final String? username;

  UserModel({required this.uid, this.email, this.username});

  // تحويل الـ UserModel لـ Map عشان تخزنه في Firestore
  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'username': username};
  }

  // إنشاء UserModel من Map (مثل البيانات اللي جايه من Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      username: map['username'],
    );
  }
}
