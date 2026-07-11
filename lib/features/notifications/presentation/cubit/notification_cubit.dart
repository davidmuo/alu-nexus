import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_model.dart';
import '../../../../core/constants/firebase_constants.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  StreamSubscription<List<NotificationModel>>? _sub;

  NotificationCubit() : super(const NotificationInitial());

  void loadNotifications(String userId) {
    _sub?.cancel();
    _sub = _firestore
        .collection(FirebaseConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(NotificationModel.fromFirestore).toList())
        .listen(
          (list) {
            final unread = list.where((n) => !n.isRead).length;
            emit(NotificationLoaded(list, unread));
          },
          onError: (e) => emit(NotificationError(e.toString())),
        );
  }

  Future<void> markAllRead(String userId) async {
    final snap = await _firestore
        .collection(FirebaseConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> markRead(String notifId) async {
    await _firestore
        .collection(FirebaseConstants.notificationsCollection)
        .doc(notifId)
        .update({'isRead': true});
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
