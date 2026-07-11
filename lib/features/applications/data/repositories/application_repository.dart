import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';
import '../../../../core/constants/firebase_constants.dart';

class ApplicationRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  ApplicationRepository();

  Future<ApplicationModel> submitApplication(ApplicationModel app) async {
    // Check if already applied
    final existing = await _firestore
        .collection(FirebaseConstants.applicationsCollection)
        .where('applicantId', isEqualTo: app.applicantId)
        .where('opportunityId', isEqualTo: app.opportunityId)
        .get();

    if (existing.docs.isNotEmpty) throw Exception('You have already applied for this opportunity.');

    final ref = _firestore.collection(FirebaseConstants.applicationsCollection).doc();
    final model = ApplicationModel(
      id: ref.id,
      opportunityId: app.opportunityId,
      opportunityTitle: app.opportunityTitle,
      startupId: app.startupId,
      startupName: app.startupName,
      startupLogoUrl: app.startupLogoUrl,
      applicantId: app.applicantId,
      applicantName: app.applicantName,
      applicantEmail: app.applicantEmail,
      applicantPhotoUrl: app.applicantPhotoUrl,
      coverLetter: app.coverLetter,
      portfolioUrl: app.portfolioUrl,
      resumeUrl: app.resumeUrl,
      status: 'pending',
      skills: app.skills,
      appliedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await ref.set(model.toMap());

    // Increment opportunity application count
    await _firestore
        .collection(FirebaseConstants.opportunitiesCollection)
        .doc(app.opportunityId)
        .update({'applicationCount': FieldValue.increment(1)});

    return model;
  }

  Stream<List<ApplicationModel>> getStudentApplications(String studentId) {
    return _firestore
        .collection(FirebaseConstants.applicationsCollection)
        .where('applicantId', isEqualTo: studentId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ApplicationModel.fromFirestore).toList());
  }

  Stream<List<ApplicationModel>> getStartupApplications(String startupId) {
    return _firestore
        .collection(FirebaseConstants.applicationsCollection)
        .where('startupId', isEqualTo: startupId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ApplicationModel.fromFirestore).toList());
  }

  Stream<List<ApplicationModel>> getOpportunityApplications(String opportunityId) {
    return _firestore
        .collection(FirebaseConstants.applicationsCollection)
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ApplicationModel.fromFirestore).toList());
  }

  Future<void> updateApplicationStatus(
    String appId,
    String status, {
    String? note,
    DateTime? interviewDate,
  }) async {
    final data = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (note != null) data['statusNote'] = note;
    if (interviewDate != null) {
      data['interviewDate'] = Timestamp.fromDate(interviewDate);
    }
    await _firestore
        .collection(FirebaseConstants.applicationsCollection)
        .doc(appId)
        .update(data);
  }

  Future<void> withdrawApplication(String appId) =>
      updateApplicationStatus(appId, 'withdrawn');

  Future<bool> hasApplied(String studentId, String opportunityId) async {
    final snap = await _firestore
        .collection(FirebaseConstants.applicationsCollection)
        .where('applicantId', isEqualTo: studentId)
        .where('opportunityId', isEqualTo: opportunityId)
        .get();
    return snap.docs.isNotEmpty;
  }
}
