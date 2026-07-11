import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity_model.dart';
import '../../../../core/constants/firebase_constants.dart';

class OpportunityRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  OpportunityRepository();

  Future<OpportunityModel> createOpportunity(OpportunityModel opp) async {
    final ref = _firestore.collection(FirebaseConstants.opportunitiesCollection).doc();
    final model = OpportunityModel(
      id: ref.id,
      startupId: opp.startupId,
      startupName: opp.startupName,
      startupLogoUrl: opp.startupLogoUrl,
      startupVerified: opp.startupVerified,
      title: opp.title,
      description: opp.description,
      type: opp.type,
      skills: opp.skills,
      commitment: opp.commitment,
      duration: opp.duration,
      isPaid: opp.isPaid,
      compensation: opp.compensation,
      location: opp.location,
      applicationDeadline: opp.applicationDeadline,
      deadline: opp.deadline,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      responsibilities: opp.responsibilities,
      requirements: opp.requirements,
      perks: opp.perks,
      maxApplicants: opp.maxApplicants,
    );
    await ref.set(model.toMap());

    // Increment startup opportunity count
    await _firestore
        .collection(FirebaseConstants.startupsCollection)
        .doc(opp.startupId)
        .update({'opportunitiesCount': FieldValue.increment(1)});

    return model;
  }

  Stream<List<OpportunityModel>> getActiveOpportunities({
    String? type,
    String? commitment,
    String? searchQuery,
    bool? isPaid,
  }) {
    Query query = _firestore
        .collection(FirebaseConstants.opportunitiesCollection)
        .where('isActive', isEqualTo: true)
        .where('startupVerified', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (type != null && type.isNotEmpty) {
      query = query.where('type', isEqualTo: type);
    }
    if (commitment != null && commitment.isNotEmpty) {
      query = query.where('commitment', isEqualTo: commitment);
    }
    if (isPaid != null) {
      query = query.where('isPaid', isEqualTo: isPaid);
    }

    return query.snapshots().map(
          (snap) => snap.docs
              .map((doc) => OpportunityModel.fromFirestore(doc))
              .where((o) {
                if (searchQuery == null || searchQuery.isEmpty) return true;
                final q = searchQuery.toLowerCase();
                return o.title.toLowerCase().contains(q) ||
                    o.startupName.toLowerCase().contains(q) ||
                    o.description.toLowerCase().contains(q) ||
                    o.skills.any((s) => s.toLowerCase().contains(q));
              })
              .toList(),
        );
  }

  Stream<List<OpportunityModel>> getStartupOpportunities(String startupId) {
    return _firestore
        .collection(FirebaseConstants.opportunitiesCollection)
        .where('startupId', isEqualTo: startupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OpportunityModel.fromFirestore).toList());
  }

  Future<OpportunityModel?> getById(String id) async {
    final doc = await _firestore
        .collection(FirebaseConstants.opportunitiesCollection)
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return OpportunityModel.fromFirestore(doc);
  }

  Future<void> incrementViewCount(String id) {
    return _firestore
        .collection(FirebaseConstants.opportunitiesCollection)
        .doc(id)
        .update({'viewCount': FieldValue.increment(1)});
  }

  Future<void> closeOpportunity(String id) {
    return _firestore
        .collection(FirebaseConstants.opportunitiesCollection)
        .doc(id)
        .update({'isActive': false, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<List<OpportunityModel>> getRecommendedOpportunities(
    List<String> userSkills,
  ) async {
    final snap = await _firestore
        .collection(FirebaseConstants.opportunitiesCollection)
        .where('isActive', isEqualTo: true)
        .where('startupVerified', isEqualTo: true)
        .where('skills', arrayContainsAny: userSkills.take(10).toList())
        .limit(10)
        .get();
    return snap.docs.map(OpportunityModel.fromFirestore).toList();
  }
}
