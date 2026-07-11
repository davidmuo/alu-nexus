import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/startup_model.dart';
import '../../../opportunities/data/models/opportunity_model.dart';
import '../../../opportunities/data/repositories/opportunity_repository.dart';
import '../../../opportunities/presentation/screens/opportunity_detail_screen.dart';
import '../../../../core/theme/app_colors.dart';

class StartupDetailScreen extends StatelessWidget {
  final StartupModel startup;

  const StartupDetailScreen({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    final s = startup;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Banner
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      image: s.bannerUrl != null
                          ? DecorationImage(
                              image: NetworkImage(s.bannerUrl!),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                AppColors.primary.withValues(alpha: 0.6),
                                BlendMode.srcOver,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: s.logoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(s.logoUrl!, fit: BoxFit.cover),
                                )
                              : const Icon(Icons.business, color: AppColors.grey400, size: 32),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.verified, color: AppColors.accent, size: 14),
                                const SizedBox(width: 4),
                                const Text(
                                  'ALU Verified',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta
                  Row(
                    children: [
                      _InfoChip(icon: Icons.category_outlined, label: s.industry),
                      const SizedBox(width: 8),
                      _InfoChip(icon: Icons.trending_up, label: _stageLabel(s.stage)),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: 12),
                  Text(
                    '"${s.tagline}"',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.grey700,
                        ),
                  ).animate().fadeIn(delay: 50.ms),
                  const SizedBox(height: 20),
                  Text('About', style: Theme.of(context).textTheme.titleLarge)
                      .animate().fadeIn(delay: 80.ms),
                  const SizedBox(height: 8),
                  Text(
                    s.description,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: AppColors.grey700,
                          height: 1.6,
                        ),
                  ).animate().fadeIn(delay: 100.ms),
                  if (s.focusAreas.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('What they\'re building', style: Theme.of(context).textTheme.titleLarge)
                        .animate().fadeIn(delay: 120.ms),
                    const SizedBox(height: 10),
                    Text(
                      s.focusAreas.join('  ·  '),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.tagPurple,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                      ),
                    ).animate().fadeIn(delay: 140.ms),
                  ],
                  // Links
                  if (s.websiteUrl != null || s.linkedinUrl != null) ...[
                    const SizedBox(height: 24),
                    Text('Links', style: Theme.of(context).textTheme.titleLarge)
                        .animate().fadeIn(delay: 160.ms),
                    const SizedBox(height: 10),
                    if (s.websiteUrl != null)
                      _LinkRow(icon: Icons.language, label: 'Website', url: s.websiteUrl!),
                    if (s.linkedinUrl != null)
                      _LinkRow(icon: Icons.link, label: 'LinkedIn', url: s.linkedinUrl!),
                  ],
                  const SizedBox(height: 24),
                  Text('Open positions',
                          style: Theme.of(context).textTheme.titleLarge)
                      .animate()
                      .fadeIn(delay: 180.ms),
                  const SizedBox(height: 12),
                  _OpenPositions(startupId: s.id)
                      .animate()
                      .fadeIn(delay: 200.ms),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stageLabel(String stage) {
    switch (stage) {
      case 'idea': return 'Idea Stage';
      case 'mvp': return 'MVP';
      case 'growth': return 'Growing';
      case 'scaling': return 'Scaling';
      default: return stage;
    }
  }
}

/// Live list of the startup's open opportunities — tap through to apply.
class _OpenPositions extends StatelessWidget {
  final String startupId;
  const _OpenPositions({required this.startupId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OpportunityModel>>(
      stream: OpportunityRepository().getStartupOpportunities(startupId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final open =
            (snap.data ?? const []).where((o) => o.isActive).toList();
        if (open.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'No open roles right now.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.grey500),
              ),
            ),
          );
        }
        return Column(
          children: open.asMap().entries.map((e) {
            final opp = e.value;
            final color =
                AppColors.cardColors[e.key % AppColors.cardColors.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.grey200),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OpportunityDetailScreen(
                        opportunity: opp,
                        accentColor: color,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opp.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${opp.commitment} · ${opp.duration} · ${opp.isPaid ? (opp.compensation ?? 'Paid') : 'Volunteer'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.tagPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppColors.grey400, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.grey600),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey700,
                ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _LinkRow({required this.icon, required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              url,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.grey500,
                    decoration: TextDecoration.underline,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
