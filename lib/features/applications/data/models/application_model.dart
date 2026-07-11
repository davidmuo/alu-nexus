import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String? startupLogoUrl;
  final String applicantId;
  final String applicantName;
  final String applicantEmail;
  final String? applicantPhotoUrl;
  final String coverLetter;
  final String? portfolioUrl;
  final String? resumeUrl;
  final String status; // pending | reviewing | shortlisted | interviewing | accepted | rejected | withdrawn
  final String? statusNote;
  final List<String> skills;
  final DateTime appliedAt;
  final DateTime updatedAt;
  final DateTime? interviewDate;
  final bool isRead; // by startup

  const ApplicationModel({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    this.startupLogoUrl,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    this.applicantPhotoUrl,
    required this.coverLetter,
    this.portfolioUrl,
    this.resumeUrl,
    required this.status,
    this.statusNote,
    required this.skills,
    required this.appliedAt,
    required this.updatedAt,
    this.interviewDate,
    this.isRead = false,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isWithdrawn => status == 'withdrawn';
  bool get isActive => !isRejected && !isWithdrawn;

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Under Review';
      case 'reviewing': return 'Being Reviewed';
      case 'shortlisted': return 'Shortlisted';
      case 'interviewing': return 'Interview Scheduled';
      case 'accepted': return 'Accepted!';
      case 'rejected': return 'Not Selected';
      case 'withdrawn': return 'Withdrawn';
      default: return 'Pending';
    }
  }

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      id: doc.id,
      opportunityId: d['opportunityId'] ?? '',
      opportunityTitle: d['opportunityTitle'] ?? '',
      startupId: d['startupId'] ?? '',
      startupName: d['startupName'] ?? '',
      startupLogoUrl: d['startupLogoUrl'],
      applicantId: d['applicantId'] ?? '',
      applicantName: d['applicantName'] ?? '',
      applicantEmail: d['applicantEmail'] ?? '',
      applicantPhotoUrl: d['applicantPhotoUrl'],
      coverLetter: d['coverLetter'] ?? '',
      portfolioUrl: d['portfolioUrl'],
      resumeUrl: d['resumeUrl'],
      status: d['status'] ?? 'pending',
      statusNote: d['statusNote'],
      skills: List<String>.from(d['skills'] ?? []),
      appliedAt: (d['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      interviewDate: (d['interviewDate'] as Timestamp?)?.toDate(),
      isRead: d['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupId': startupId,
      'startupName': startupName,
      'startupLogoUrl': startupLogoUrl,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'applicantPhotoUrl': applicantPhotoUrl,
      'coverLetter': coverLetter,
      'portfolioUrl': portfolioUrl,
      'resumeUrl': resumeUrl,
      'status': status,
      'statusNote': statusNote,
      'skills': skills,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'interviewDate': interviewDate != null ? Timestamp.fromDate(interviewDate!) : null,
      'isRead': isRead,
    };
  }

  ApplicationModel copyWith({String? status, String? statusNote, DateTime? interviewDate}) {
    return ApplicationModel(
      id: id,
      opportunityId: opportunityId,
      opportunityTitle: opportunityTitle,
      startupId: startupId,
      startupName: startupName,
      startupLogoUrl: startupLogoUrl,
      applicantId: applicantId,
      applicantName: applicantName,
      applicantEmail: applicantEmail,
      applicantPhotoUrl: applicantPhotoUrl,
      coverLetter: coverLetter,
      portfolioUrl: portfolioUrl,
      resumeUrl: resumeUrl,
      status: status ?? this.status,
      statusNote: statusNote ?? this.statusNote,
      skills: skills,
      appliedAt: appliedAt,
      updatedAt: DateTime.now(),
      interviewDate: interviewDate ?? this.interviewDate,
      isRead: isRead,
    );
  }
}
