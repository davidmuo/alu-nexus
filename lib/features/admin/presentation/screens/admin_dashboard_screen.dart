import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../startups/data/models/startup_model.dart';
import '../../../startups/presentation/cubit/startup_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/loading_overlay.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    context.read<StartupCubit>().loadAllStartups();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Admin Dashboard', style: TextStyle(color: AppColors.white)),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: BlocBuilder<StartupCubit, StartupState>(
        builder: (context, state) {
          if (state is StartupLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StartupsLoaded) {
            final pending = state.startups.where((s) => s.isPending).toList();
            final approved = state.startups.where((s) => s.isVerified).toList();
            final rejected = state.startups.where((s) => s.isRejected).toList();

            return TabBarView(
              controller: _tabCtrl,
              children: [
                _StartupList(startups: pending, isPendingView: true),
                _StartupList(startups: approved),
                _StartupList(startups: rejected),
              ],
            );
          }
          return const EmptyStateWidget(
            icon: Icons.business_outlined,
            title: 'No startups found',
            subtitle: '',
          );
        },
      ),
    );
  }
}

class _StartupList extends StatelessWidget {
  final List<StartupModel> startups;
  final bool isPendingView;

  const _StartupList({required this.startups, this.isPendingView = false});

  @override
  Widget build(BuildContext context) {
    if (startups.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.business_outlined,
        title: isPendingView ? 'No pending requests' : 'No startups here',
        subtitle: '',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: startups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => AdminStartupCard(
        startup: startups[i],
        isPendingView: isPendingView,
      ).animate().fadeIn(delay: Duration(milliseconds: i * 40)),
    );
  }
}

class AdminStartupCard extends StatelessWidget {
  final StartupModel startup;
  final bool isPendingView;

  const AdminStartupCard({super.key, required this.startup, this.isPendingView = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business, color: AppColors.grey400),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(startup.name, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      startup.industry,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppColors.grey500,
                          ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: startup.verificationStatus),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            startup.tagline,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.grey600,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            startup.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.grey700),
          ),
          if (startup.aluRegistrationNumber != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.badge_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'ALU Reg: ${startup.aluRegistrationNumber}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Submitted ${startup.createdAt.timeAgo}',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.grey400),
          ),
          if (isPendingView) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDecision(context, startup, false),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDecision(context, startup, true),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showDecision(BuildContext context, StartupModel startup, bool approve) {
    final noteCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bCtx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(bCtx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              approve ? 'Approve "${startup.name}"?' : 'Reject "${startup.name}"?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(
                labelText: approve ? 'Note (optional)' : 'Reason for rejection',
                hintText: approve
                    ? 'e.g., Great product with strong ALU connection'
                    : 'e.g., Unable to verify ALU affiliation',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<StartupCubit>().verifyStartup(
                    startup.id,
                    approved: approve,
                    note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                  );
                  Navigator.pop(bCtx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: approve ? AppColors.success : AppColors.error,
                ),
                child: Text(approve ? 'Confirm Approval' : 'Confirm Rejection'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'approved':
        color = AppColors.success;
        label = 'Approved';
        break;
      case 'rejected':
        color = AppColors.error;
        label = 'Rejected';
        break;
      default:
        color = AppColors.warning;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
