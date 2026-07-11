import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../applications/presentation/cubit/application_cubit.dart';
import '../../../../core/theme/app_colors.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }
        final user = state.user;
        return Scaffold(
          backgroundColor: AppColors.grey50,
          appBar: AppBar(
            backgroundColor: AppColors.grey50,
            title: const Text('Profile'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => context.push('/notifications'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Identity
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primarySurface,
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : '?',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(color: AppColors.primary),
                        )
                      : null,
                ).animate().fadeIn(),
                const SizedBox(height: 14),
                Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: AppColors.grey500),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school_outlined,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text(
                        'ALU Student',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Stats — live from application data
                BlocBuilder<ApplicationCubit, ApplicationState>(
                  builder: (context, appState) {
                    var total = 0, shortlisted = 0, accepted = 0;
                    if (appState is ApplicationLoaded) {
                      total = appState.applications.length;
                      shortlisted = appState.applications
                          .where((a) =>
                              a.status == 'shortlisted' ||
                              a.status == 'interviewing')
                          .length;
                      accepted = appState.applications
                          .where((a) => a.status == 'accepted')
                          .length;
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Row(
                        children: [
                          _StatItem(value: '$total', label: 'Applications'),
                          const _StatDivider(),
                          _StatItem(
                              value: '$shortlisted', label: 'Shortlisted'),
                          const _StatDivider(),
                          _StatItem(value: '$accepted', label: 'Accepted'),
                        ],
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 50.ms),
                const SizedBox(height: 24),
                // Menu
                _MenuSection(
                  title: 'Activity',
                  items: [
                    _MenuItem(
                      icon: Icons.bookmark_border_rounded,
                      label: 'Saved opportunities',
                      onTap: () => context.push('/bookmarks'),
                    ),
                    _MenuItem(
                      icon: Icons.notifications_none_rounded,
                      label: 'Notifications',
                      onTap: () => context.push('/notifications'),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 12),
                _MenuSection(
                  title: 'Account',
                  items: [
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      label: 'Sign out',
                      color: AppColors.error,
                      onTap: () => _signOut(context),
                    ),
                  ],
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 24),
                Text(
                  'ALU Nexus v1.0.0',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.grey400),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will be signed out of ALU Nexus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().signOut();
              context.go('/login');
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: AppColors.grey500),
          ),
        ),
        Material(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.grey200),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast) const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.grey800;
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color != null ? AppColors.errorLight : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? AppColors.primary, size: 19),
      ),
      title: Text(
        label,
        style:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c),
      ),
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.grey400, size: 20),
      onTap: onTap,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.grey900,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.grey500,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: AppColors.grey200);
  }
}
