import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/application_model.dart';
import '../cubit/application_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/loading_overlay.dart';

class ApplicationTrackerScreen extends StatefulWidget {
  final bool isStartupView;
  const ApplicationTrackerScreen({super.key, this.isStartupView = false});

  @override
  State<ApplicationTrackerScreen> createState() => _ApplicationTrackerScreenState();
}

class _ApplicationTrackerScreenState extends State<ApplicationTrackerScreen> {
  String _statusFilter = 'all';

  static const _statuses = [
    'all',
    'pending',
    'shortlisted',
    'interviewing',
    'accepted',
  ];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  void _loadApplications() {
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    if (widget.isStartupView) {
      // Startup loads startup-specific
    } else {
      context.read<ApplicationCubit>().loadStudentApplications(user.uid);
    }
  }

  List<ApplicationModel> _filter(List<ApplicationModel> apps) {
    if (_statusFilter == 'all') return apps;
    return apps.where((a) => a.status == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        title: Text(widget.isStartupView ? 'Applicants' : 'My applications'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              itemCount: _statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final s = _statuses[i];
                final selected = _statusFilter == s;
                return GestureDetector(
                  onTap: () => setState(() => _statusFilter = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.black : AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color:
                            selected ? AppColors.black : AppColors.grey200,
                      ),
                    ),
                    child: Text(
                      s == 'all' ? 'All' : s.capitalize,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? AppColors.white : AppColors.grey600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<ApplicationCubit, ApplicationState>(
        builder: (context, state) {
          if (state is ApplicationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ApplicationLoaded) {
            final filtered = _filter(state.applications);
            if (filtered.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.assignment_outlined,
                title: _statusFilter == 'all'
                    ? 'No applications yet'
                    : 'No ${_statusFilter.capitalize} applications',
                subtitle: widget.isStartupView
                    ? 'Applications from students will appear here once you post opportunities'
                    : 'Start exploring opportunities and apply!',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => ApplicationCard(
                application: filtered[i],
                isStartupView: widget.isStartupView,
              ).animate().fadeIn(delay: Duration(milliseconds: i * 50)),
            );
          }
          return const EmptyStateWidget(
            icon: Icons.assignment_outlined,
            title: 'No applications yet',
            subtitle: 'Applications will appear here',
          );
        },
      ),
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final bool isStartupView;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.isStartupView,
  });

  Color get _statusColor {
    switch (application.status) {
      case 'pending': return AppColors.warning;
      case 'reviewing': return AppColors.info;
      case 'shortlisted': return AppColors.primary;
      case 'interviewing': return AppColors.accent;
      case 'accepted': return AppColors.success;
      case 'rejected': return AppColors.error;
      case 'withdrawn': return AppColors.grey500;
      default: return AppColors.grey500;
    }
  }

  Color get _statusBgColor {
    switch (application.status) {
      case 'pending': return AppColors.warningLight;
      case 'reviewing': return AppColors.infoLight;
      case 'shortlisted': return AppColors.primary.withValues(alpha: 0.1);
      case 'interviewing': return AppColors.accent.withValues(alpha: 0.1);
      case 'accepted': return AppColors.successLight;
      case 'rejected': return AppColors.errorLight;
      case 'withdrawn': return AppColors.grey100;
      default: return AppColors.grey100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.grey200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: application.startupLogoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(application.startupLogoUrl!, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.business, color: AppColors.grey400, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.opportunityTitle,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      isStartupView
                          ? application.applicantName
                          : application.startupName,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppColors.grey600,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  application.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (application.statusNote != null && application.statusNote!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                application.statusNote!,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.grey700),
              ),
            ),
          ],
          if (application.interviewDate != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(
                  'Interview: ${application.interviewDate!.shortDateTime}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.accentDark,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              _StatusStep(label: 'Applied', isDone: true),
              _StepConnector(isDone: application.status != 'pending'),
              _StatusStep(
                label: 'Reviewing',
                isDone: ['reviewing', 'shortlisted', 'interviewing', 'accepted'].contains(application.status),
              ),
              _StepConnector(
                isDone: ['shortlisted', 'interviewing', 'accepted'].contains(application.status),
              ),
              _StatusStep(
                label: 'Shortlisted',
                isDone: ['shortlisted', 'interviewing', 'accepted'].contains(application.status),
              ),
              _StepConnector(
                isDone: ['interviewing', 'accepted'].contains(application.status),
              ),
              _StatusStep(
                label: 'Accepted',
                isDone: application.status == 'accepted',
                isActive: application.status == 'interviewing',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Applied ${application.appliedAt.timeAgo}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.grey500),
              ),
              const Spacer(),
              if (isStartupView && application.status == 'pending')
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _showStatusUpdate(context, application),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('Update Status'),
                    ),
                  ],
                ),
              if (!isStartupView && application.isActive)
                TextButton(
                  onPressed: () => _confirmWithdraw(context, application),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Withdraw'),
                ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  void _showStatusUpdate(BuildContext context, ApplicationModel app) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Application Status', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...['reviewing', 'shortlisted', 'interviewing', 'accepted', 'rejected']
                .map((status) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(status.capitalize),
                      onTap: () {
                        context.read<ApplicationCubit>().updateStatus(app.id, status);
                        Navigator.pop(context);
                      },
                    )),
          ],
        ),
      ),
    );
  }

  void _confirmWithdraw(BuildContext context, ApplicationModel app) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Withdraw Application?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ApplicationCubit>().withdraw(app.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isActive;

  const _StatusStep({required this.label, required this.isDone, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppColors.primary : AppColors.grey200,
            border: isActive
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: isDone ? const Icon(Icons.check, size: 10, color: AppColors.white) : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isDone ? AppColors.primary : AppColors.grey400,
            fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isDone;
  const _StepConnector({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: isDone ? AppColors.primary : AppColors.grey200,
      ),
    );
  }
}
