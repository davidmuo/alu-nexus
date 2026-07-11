import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/notification_cubit.dart';
import '../../data/models/notification_model.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/loading_overlay.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
                    context.read<NotificationCubit>().markAllRead(user.uid);
                  },
                  child: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.notifications_none,
                title: 'No notifications',
                subtitle: 'You\'re all caught up! Notifications will appear here.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final notif = state.notifications[i];
                return _NotificationTile(notification: notif)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: i * 40));
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.applicationReceived: return Icons.person_add_outlined;
      case NotificationType.applicationStatusUpdate: return Icons.update_outlined;
      case NotificationType.newOpportunity: return Icons.work_outline;
      case NotificationType.startupVerified: return Icons.verified_outlined;
      case NotificationType.startupRejected: return Icons.cancel_outlined;
      case NotificationType.interviewScheduled: return Icons.calendar_today;
      case NotificationType.message: return Icons.message_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.applicationStatusUpdate:
        return AppColors.info;
      case NotificationType.startupVerified:
        return AppColors.success;
      case NotificationType.startupRejected:
        return AppColors.error;
      case NotificationType.interviewScheduled:
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationCubit>().markRead(notification.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.white : AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead ? AppColors.grey200 : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColors.grey600,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.createdAt.timeAgo,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColors.grey400,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
