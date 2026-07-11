import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/app_user.dart';
import '../models/user_model.dart';
import '../../../../core/constants/firebase_constants.dart';

class AuthRepository {
  // Lazy — only accessed when a method is actually called
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  AuthRepository();

  Stream<AppUser?> get authStateChanges => _auth.authStateChanges().asyncMap(
        (user) async {
          if (user == null) return null;
          return _getUserData(user.uid);
        },
      );

  Future<AppUser?> get currentUser async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _getUserData(user.uid);
  }

  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final model = UserModel(
      uid: cred.user!.uid,
      email: email,
      displayName: displayName,
      role: role,
      isOnboardingComplete: false,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(cred.user!.uid)
        .set(model.toMap());

    await cred.user!.updateDisplayName(displayName);

    return model;
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = await _getUserData(cred.user!.uid);
    if (user == null) throw Exception('User data not found');
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<AppUser> completeOnboarding(
    String uid,
    Map<String, dynamic> profileData,
  ) async {
    await _firestore.collection(FirebaseConstants.usersCollection).doc(uid).update({
      ...profileData,
      'isOnboardingComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final user = await _getUserData(uid);
    return user!;
  }

  Future<AppUser?> _getUserData(String uid) async {
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }
}
