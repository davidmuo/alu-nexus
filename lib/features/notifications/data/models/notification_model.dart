import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  applicationReceived,
  applicationStatusUpdate,
  newOpportunity,
  startupVerified,
  startupRejected,
  interviewScheduled,
  message,
  general,
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? referenceId; // opportunityId | applicationId | startupId
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == d['type'],
        orElse: () => NotificationType.general,
      ),
      referenceId: d['referenceId'],
      isRead: d['isRead'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'referenceId': referenceId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
