import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/startup_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/repositories/startup_repository.dart';
import '../../../opportunities/presentation/screens/post_opportunity_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_overlay.dart';

class StartupProfileScreen extends StatefulWidget {
  const StartupProfileScreen({super.key});

  @override
  State<StartupProfileScreen> createState() => _StartupProfileScreenState();
}

class _StartupProfileScreenState extends State<StartupProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadStartup();
  }

  Future<void> _loadStartup() async {
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    final startup = await StartupRepository().getStartupByOwner(user.uid);
    if (startup != null && mounted) {
      context.read<StartupCubit>().watchStartup(startup.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('My Startup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: BlocBuilder<StartupCubit, StartupState>(
        builder: (context, state) {
          if (state is StartupLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StartupDetailLoaded) {
            final s = state.startup;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Verification status
                  _VerificationBanner(status: s.verificationStatus)
                      .animate().fadeIn(),
                  const SizedBox(height: 16),
                  // Profile card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: s.logoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(s.logoUrl!, fit: BoxFit.cover),
                                )
                              : const Icon(Icons.business, color: AppColors.grey400, size: 36),
                        ),
                        const SizedBox(height: 12),
                        Text(s.name, style: Theme.of(context).textTheme.headlineSmall),
                        Text(
                          s.tagline,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: AppColors.grey500,
                                fontStyle: FontStyle.italic,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _Stat(value: '${s.opportunitiesCount}', label: 'Roles'),
                            Container(width: 1, height: 36, color: AppColors.grey200),
                            _Stat(value: '${s.followersCount}', label: 'Followers'),
                            Container(width: 1, height: 36, color: AppColors.grey200),
                            _Stat(value: s.stage.toUpperCase(), label: 'Stage'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PostOpportunityScreen()),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Post Opportunity'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 50.ms),
                ],
              ),
            );
          }
          return const EmptyStateWidget(
            icon: Icons.business_outlined,
            title: 'No startup profile found',
            subtitle: 'Something went wrong. Please contact support.',
          );
        },
      ),
    );
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out?'),
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
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  final String status;
  const _VerificationBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    IconData icon;
    String label;
    String subtitle;

    switch (status) {
      case 'approved':
        color = AppColors.success;
        bgColor = AppColors.successLight;
        icon = Icons.verified;
        label = 'Verified ALU Startup';
        subtitle = 'Your startup is fully verified. Opportunities are visible to all students.';
        break;
      case 'rejected':
        color = AppColors.error;
        bgColor = AppColors.errorLight;
        icon = Icons.cancel_outlined;
        label = 'Verification Rejected';
        subtitle = 'Please contact ALU administration for more information.';
        break;
      default:
        color = AppColors.warning;
        bgColor = AppColors.warningLight;
        icon = Icons.hourglass_empty;
        label = 'Verification Pending';
        subtitle = 'Your startup is under review. Typically takes 1–3 business days.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(color: color),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.grey700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.grey500),
        ),
      ],
    );
  }
}
