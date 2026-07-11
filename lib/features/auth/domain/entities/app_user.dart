import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated ALU Nexus user.
///
/// A user is either a `student`, a `startup` owner, or an `admin`.
/// [skills] is populated during student onboarding and drives the
/// skill-matching recommendation on the opportunity feed.
class AppUser extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'student' | 'startup' | 'admin'
  final String? photoUrl;
  final List<String> skills;
  final bool isOnboardingComplete;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoUrl,
    this.skills = const [],
    required this.isOnboardingComplete,
    required this.createdAt,
  });

  bool get isStudent => role == 'student';
  bool get isStartup => role == 'startup';
  bool get isAdmin => role == 'admin';

  AppUser copyWith({
    String? displayName,
    String? photoUrl,
    List<String>? skills,
    bool? isOnboardingComplete,
    String? role,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      skills: skills ?? this.skills,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [uid, email, role, skills, isOnboardingComplete];
}
