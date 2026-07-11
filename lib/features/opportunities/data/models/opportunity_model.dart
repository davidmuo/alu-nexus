import 'package:cloud_firestore/cloud_firestore.dart';

class OpportunityModel {
  final String id;
  final String startupId;
  final String startupName;
  final String? startupLogoUrl;
  final bool startupVerified;
  final String title;
  final String description;
  final String type; // role category
  final List<String> skills;
  final String commitment; // Full-time | Part-time | Flexible | Remote | Hybrid
  final String duration;
  final bool isPaid;
  final String? compensation;
  final String location;
  final int applicationDeadline; // days from now
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int applicationCount;
  final int viewCount;
  final List<String> responsibilities;
  final List<String> requirements;
  final String? perks;
  final int maxApplicants;

  const OpportunityModel({
    required this.id,
    required this.startupId,
    required this.startupName,
    this.startupLogoUrl,
    required this.startupVerified,
    required this.title,
    required this.description,
    required this.type,
    required this.skills,
    required this.commitment,
    required this.duration,
    required this.isPaid,
    this.compensation,
    required this.location,
    required this.applicationDeadline,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.applicationCount = 0,
    this.viewCount = 0,
    required this.responsibilities,
    required this.requirements,
    this.perks,
    this.maxApplicants = 20,
  });

  bool get isExpired => DateTime.now().isAfter(deadline);
  bool get isClosingSoon =>
      !isExpired && deadline.difference(DateTime.now()).inDays <= 3;

  factory OpportunityModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OpportunityModel(
      id: doc.id,
      startupId: d['startupId'] ?? '',
      startupName: d['startupName'] ?? '',
      startupLogoUrl: d['startupLogoUrl'],
      startupVerified: d['startupVerified'] ?? false,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      type: d['type'] ?? '',
      skills: List<String>.from(d['skills'] ?? []),
      commitment: d['commitment'] ?? 'Flexible',
      duration: d['duration'] ?? '3 months',
      isPaid: d['isPaid'] ?? false,
      compensation: d['compensation'],
      location: d['location'] ?? 'Remote',
      applicationDeadline: d['applicationDeadline'] ?? 14,
      deadline: (d['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: d['isActive'] ?? true,
      applicationCount: d['applicationCount'] ?? 0,
      viewCount: d['viewCount'] ?? 0,
      responsibilities: List<String>.from(d['responsibilities'] ?? []),
      requirements: List<String>.from(d['requirements'] ?? []),
      perks: d['perks'],
      maxApplicants: d['maxApplicants'] ?? 20,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'startupLogoUrl': startupLogoUrl,
      'startupVerified': startupVerified,
      'title': title,
      'description': description,
      'type': type,
      'skills': skills,
      'commitment': commitment,
      'duration': duration,
      'isPaid': isPaid,
      'compensation': compensation,
      'location': location,
      'applicationDeadline': applicationDeadline,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': isActive,
      'applicationCount': applicationCount,
      'viewCount': viewCount,
      'responsibilities': responsibilities,
      'requirements': requirements,
      'perks': perks,
      'maxApplicants': maxApplicants,
    };
  }
}
