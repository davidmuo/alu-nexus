import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/startup_model.dart';
import '../cubit/startup_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_overlay.dart';
import 'startup_detail_screen.dart';

class StartupDirectoryScreen extends StatefulWidget {
  const StartupDirectoryScreen({super.key});

  @override
  State<StartupDirectoryScreen> createState() => _StartupDirectoryScreenState();
}

class _StartupDirectoryScreenState extends State<StartupDirectoryScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    context.read<StartupCubit>().loadVerifiedStartups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Startups'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search verified startups...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
          ),
        ),
      ),
      body: BlocBuilder<StartupCubit, StartupState>(
        builder: (context, state) {
          if (state is StartupLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StartupsLoaded) {
            final list = _search.isEmpty
                ? state.startups
                : state.startups
                    .where((s) =>
                        s.name.toLowerCase().contains(_search) ||
                        s.industry.toLowerCase().contains(_search) ||
                        s.tagline.toLowerCase().contains(_search))
                    .toList();

            if (list.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.business_outlined,
                title: 'No startups found',
                subtitle: 'Verified ALU startups will appear here',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => StartupCard(startup: list[i])
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: i * 50)),
            );
          }
          return const EmptyStateWidget(
            icon: Icons.business_outlined,
            title: 'No startups yet',
            subtitle: 'Be the first to join ALU Nexus!',
          );
        },
      ),
    );
  }
}

class StartupCard extends StatelessWidget {
  final StartupModel startup;

  const StartupCard({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StartupDetailScreen(startup: startup)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: startup.logoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(startup.logoUrl!, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.business, color: AppColors.grey400),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            startup.name,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, color: AppColors.primary, size: 16),
                        ],
                      ),
                      Text(
                        startup.industry,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: AppColors.grey500,
                            ),
                      ),
                    ],
                  ),
                ),
                _StageChip(stage: startup.stage),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              startup.tagline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.grey600,
                  ),
            ),
            if (startup.focusAreas.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                startup.focusAreas.take(4).join('  ·  '),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.tagPurple,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.work_outline, size: 14, color: AppColors.grey500),
                const SizedBox(width: 4),
                Text(
                  '${startup.opportunitiesCount} open role${startup.opportunitiesCount != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.grey500,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  final String stage;
  const _StageChip({required this.stage});

  String get _label {
    switch (stage) {
      case 'idea': return 'Idea';
      case 'mvp': return 'MVP';
      case 'growth': return 'Growth';
      case 'scaling': return 'Scaling';
      default: return stage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.tagPurple,
      ),
    );
  }
}
