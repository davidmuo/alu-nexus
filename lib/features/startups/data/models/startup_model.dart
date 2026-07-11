import 'package:cloud_firestore/cloud_firestore.dart';

class StartupModel {
  final String id;
  final String ownerId;
  final String name;
  final String tagline;
  final String description;
  final String industry;
  final String? logoUrl;
  final String? bannerUrl;
  final String? websiteUrl;
  final String? linkedinUrl;
  final String? instagramUrl;
  final String verificationStatus; // pending | approved | rejected
  final String? verificationNote;
  final List<String> teamSize;
  final List<String> focusAreas;
  final String stage; // idea | mvp | growth | scaling
  final DateTime foundedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int opportunitiesCount;
  final int followersCount;
  final bool isActive;
  final String? rejectionReason;
  final String? aluRegistrationNumber;

  const StartupModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.tagline,
    required this.description,
    required this.industry,
    this.logoUrl,
    this.bannerUrl,
    this.websiteUrl,
    this.linkedinUrl,
    this.instagramUrl,
    required this.verificationStatus,
    this.verificationNote,
    required this.teamSize,
    required this.focusAreas,
    required this.stage,
    required this.foundedAt,
    required this.createdAt,
    required this.updatedAt,
    this.opportunitiesCount = 0,
    this.followersCount = 0,
    this.isActive = true,
    this.rejectionReason,
    this.aluRegistrationNumber,
  });

  bool get isVerified => verificationStatus == 'approved';
  bool get isPending => verificationStatus == 'pending';
  bool get isRejected => verificationStatus == 'rejected';

  factory StartupModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return StartupModel(
      id: doc.id,
      ownerId: d['ownerId'] ?? '',
      name: d['name'] ?? '',
      tagline: d['tagline'] ?? '',
      description: d['description'] ?? '',
      industry: d['industry'] ?? '',
      logoUrl: d['logoUrl'],
      bannerUrl: d['bannerUrl'],
      websiteUrl: d['websiteUrl'],
      linkedinUrl: d['linkedinUrl'],
      instagramUrl: d['instagramUrl'],
      verificationStatus: d['verificationStatus'] ?? 'pending',
      verificationNote: d['verificationNote'],
      teamSize: List<String>.from(d['teamSize'] ?? []),
      focusAreas: List<String>.from(d['focusAreas'] ?? []),
      stage: d['stage'] ?? 'idea',
      foundedAt: (d['foundedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      opportunitiesCount: d['opportunitiesCount'] ?? 0,
      followersCount: d['followersCount'] ?? 0,
      isActive: d['isActive'] ?? true,
      rejectionReason: d['rejectionReason'],
      aluRegistrationNumber: d['aluRegistrationNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'tagline': tagline,
      'description': description,
      'industry': industry,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'websiteUrl': websiteUrl,
      'linkedinUrl': linkedinUrl,
      'instagramUrl': instagramUrl,
      'verificationStatus': verificationStatus,
      'verificationNote': verificationNote,
      'teamSize': teamSize,
      'focusAreas': focusAreas,
      'stage': stage,
      'foundedAt': Timestamp.fromDate(foundedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'opportunitiesCount': opportunitiesCount,
      'followersCount': followersCount,
      'isActive': isActive,
      'aluRegistrationNumber': aluRegistrationNumber,
    };
  }

  StartupModel copyWith({
    String? name,
    String? tagline,
    String? description,
    String? logoUrl,
    String? bannerUrl,
    String? websiteUrl,
    String? verificationStatus,
    String? rejectionReason,
  }) {
    return StartupModel(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      industry: industry,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      linkedinUrl: linkedinUrl,
      instagramUrl: instagramUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationNote: verificationNote,
      teamSize: teamSize,
      focusAreas: focusAreas,
      stage: stage,
      foundedAt: foundedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      opportunitiesCount: opportunitiesCount,
      followersCount: followersCount,
      isActive: isActive,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      aluRegistrationNumber: aluRegistrationNumber,
    );
  }
}
