import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_user.dart';

/// Firestore-backed data model for [AppUser].
///
/// Handles (de)serialization between the `users` collection documents
/// and the domain entity used throughout the presentation layer.
class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    required super.role,
    super.photoUrl,
    super.skills,
    required super.isOnboardingComplete,
    required super.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(doc.id, data);
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? 'student',
      photoUrl: data['photoUrl'],
      skills: List<String>.from(data['skills'] ?? const []),
      isOnboardingComplete: data['isOnboardingComplete'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'photoUrl': photoUrl,
      'skills': skills,
      'isOnboardingComplete': isOnboardingComplete,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static UserModel fromEntity(AppUser user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      role: user.role,
      photoUrl: user.photoUrl,
      skills: user.skills,
      isOnboardingComplete: user.isOnboardingComplete,
      createdAt: user.createdAt,
    );
  }
}
