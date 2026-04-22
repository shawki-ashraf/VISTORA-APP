import 'package:cloud_firestore/cloud_firestore.dart';

class UserprofileModel {
  final String username;
  final String email;
  final String imageUrl;
  final DateTime createdAt;
  final String? location;

  UserprofileModel({
    required this.username,
    required this.email,
    required this.imageUrl,
    required this.createdAt,
    this.location,
  });

  factory UserprofileModel.fromMap(Map<String, dynamic> map) {
    return UserprofileModel(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      location: map['location'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'imageUrl': imageUrl,
      'location': location,
      'createdAt': createdAt,
    };
  }
}
