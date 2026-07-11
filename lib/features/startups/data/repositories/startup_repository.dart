import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/startup_model.dart';
import '../../../../core/constants/firebase_constants.dart';

class StartupRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  StartupRepository();

  Future<StartupModel> createStartup(StartupModel startup) async {
    final ref = _firestore.collection(FirebaseConstants.startupsCollection).doc();
    final model = StartupModel(
      id: ref.id,
      ownerId: startup.ownerId,
      name: startup.name,
      tagline: startup.tagline,
      description: startup.description,
      industry: startup.industry,
      logoUrl: startup.logoUrl,
      bannerUrl: startup.bannerUrl,
      websiteUrl: startup.websiteUrl,
      linkedinUrl: startup.linkedinUrl,
      instagramUrl: startup.instagramUrl,
      verificationStatus: 'pending',
      teamSize: startup.teamSize,
      focusAreas: startup.focusAreas,
      stage: startup.stage,
      foundedAt: startup.foundedAt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      aluRegistrationNumber: startup.aluRegistrationNumber,
    );
    await ref.set(model.toMap());
    return model;
  }

  Future<StartupModel?> getStartupById(String id) async {
    final doc = await _firestore
        .collection(FirebaseConstants.startupsCollection)
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return StartupModel.fromFirestore(doc);
  }

  Future<StartupModel?> getStartupByOwner(String ownerId) async {
    final snap = await _firestore
        .collection(FirebaseConstants.startupsCollection)
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return StartupModel.fromFirestore(snap.docs.first);
  }

  Stream<List<StartupModel>> getVerifiedStartups() {
    return _firestore
        .collection(FirebaseConstants.startupsCollection)
        .where('verificationStatus', isEqualTo: 'approved')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(StartupModel.fromFirestore).toList());
  }

  Stream<List<StartupModel>> getAllStartups() {
    return _firestore
        .collection(FirebaseConstants.startupsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(StartupModel.fromFirestore).toList());
  }

  Stream<StartupModel?> watchStartup(String id) {
    return _firestore
        .collection(FirebaseConstants.startupsCollection)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? StartupModel.fromFirestore(doc) : null);
  }

  Future<void> updateStartup(String id, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirebaseConstants.startupsCollection)
        .doc(id)
        .update({...data, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> verifyStartup(
    String startupId, {
    required bool approved,
    String? note,
    String? adminId,
  }) async {
    final status = approved ? 'approved' : 'rejected';
    await _firestore
        .collection(FirebaseConstants.startupsCollection)
        .doc(startupId)
        .update({
      'verificationStatus': status,
      'verificationNote': note,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Log admin action
    await _firestore.collection(FirebaseConstants.adminActionsCollection).add({
      'adminId': adminId,
      'targetId': startupId,
      'action': status,
      'note': note,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> uploadLogo(String startupId, File file) async {
    final ref = _storage
        .ref()
        .child('${FirebaseConstants.startupLogosPath}/$startupId.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
