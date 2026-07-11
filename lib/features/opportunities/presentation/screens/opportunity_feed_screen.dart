import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/opportunity_model.dart';
import '../cubit/opportunity_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../notifications/presentation/cubit/notification_cubit.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/bookmark_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_overlay.dart';
import 'opportunity_detail_screen.dart';

class OpportunityFeedScreen extends StatefulWidget {
  const OpportunityFeedScreen({super.key});

  @override
  State<OpportunityFeedScreen> createState() => _OpportunityFeedScreenState();
}

class _OpportunityFeedScreenState extends State<OpportunityFeedScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedType = '';
  String _selectedCommitment = '';
  bool? _paidFilter;

  static const _categories = [
    _Category('Engineering', Icons.code_rounded, 'Software Development', 0),
    _Category('Design', Icons.brush_rounded, 'UI/UX Design', 2),
    _Category('Marketing', Icons.campaign_rounded, 'Marketing', 4),
    _Category('Research', Icons.insights_rounded, 'Research & Analysis', 3),
    _Category('Community', Icons.groups_rounded, 'Community Management', 1),
    _Category('Business', Icons.trending_up_rounded, 'Business Development', 5),
  ];

  bool get _isFiltering =>
      _searchCtrl.text.isNotEmpty ||
      _selectedType.isNotEmpty ||
      _selectedCommitment.isNotEmpty ||
      _paidFilter != null;

  @override
  void initState() {
    super.initState();
    context.read<OpportunityCubit>().loadOpportunities();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _selectCategory(String type) {
    setState(() => _selectedType = _selectedType == type ? '' : type);
    context.read<OpportunityCubit>().filterByType(_selectedType);
  }

  void _clearAll() {
    setState(() {
      _searchCtrl.clear();
      _selectedType = '';
      _selectedCommitment = '';
      _paidFilter = null;
    });
    context.read<OpportunityCubit>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async =>
              context.read<OpportunityCubit>().loadOpportunities(),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _header(context),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _searchRow(context),
              ),
              const SizedBox(height: 24),
              _categoryStrip(),
              const SizedBox(height: 8),
              BlocBuilder<OpportunityCubit, OpportunityState>(
                builder: (context, state) {
                  if (state is OpportunityLoading) return const _ShimmerHome();
                  if (state is OpportunityError) {
                    return EmptyStateWidget(
                      icon: Icons.error_outline,
                      title: 'Something went wrong',
                      subtitle: state.message,
                      actionLabel: 'Retry',
                      onAction: () =>
                          context.read<OpportunityCubit>().loadOpportunities(),
                    );
                  }
                  if (state is OpportunityLoaded) {
                    return _content(context, state.opportunities);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────
  Widget _header(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final name = auth is AuthAuthenticated
        ? auth.user.displayName.split(' ').first
        : 'there';
    final photo = auth is AuthAuthenticated ? auth.user.photoUrl : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $name',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Find your next opportunity',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: AppColors.grey500),
                ),
              ],
            ),
          ),
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final unread =
                  state is NotificationLoaded ? state.unreadCount : 0;
              return _CircleIconButton(
                icon: Icons.notifications_none_rounded,
                showDot: unread > 0,
                onTap: () => context.push('/notifications'),
              );
            },
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySurface,
              image: photo != null
                  ? DecorationImage(
                      image: NetworkImage(photo), fit: BoxFit.cover)
                  : null,
            ),
            alignment: Alignment.center,
            child: photo == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  )
                : null,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  // ── Search + filter ─────────────────────────────────────
  Widget _searchRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) {
              setState(() {});
              context.read<OpportunityCubit>().search(v);
            },
            decoration: InputDecoration(
              hintText: 'Search opportunities...',
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 22, color: AppColors.grey400),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        setState(() => _searchCtrl.clear());
                        context.read<OpportunityCubit>().search('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _openFilters,
            child: SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.tune_rounded,
                      color: AppColors.white, size: 22),
                  if (_selectedCommitment.isNotEmpty || _paidFilter != null)
                    Positioned(
                      top: 12,
                      right: 13,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Category strip ──────────────────────────────────────
  Widget _categoryStrip() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final selected = _selectedType == cat.type;
          return GestureDetector(
            onTap: () => _selectCategory(cat.type),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.skillColors[cat.colorIndex],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    cat.icon,
                    color: selected
                        ? AppColors.white
                        : AppColors.skillTextColors[cat.colorIndex],
                    size: 25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.primary : AppColors.grey600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 80.ms);
  }

  // ── Content ─────────────────────────────────────────────
  Widget _content(BuildContext context, List<OpportunityModel> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: EmptyStateWidget(
          icon: Icons.search_off_rounded,
          title: 'No opportunities found',
          subtitle: 'Try adjusting your filters or search terms',
        ),
      );
    }

    if (_isFiltering) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            context,
            '${items.length} result${items.length == 1 ? '' : 's'}',
            actionLabel: 'Clear filters',
            onAction: _clearAll,
          ),
          ...items.asMap().entries.map(
                (e) => OpportunityTile(opportunity: e.value)
                    .animate()
                    .fadeIn(delay: (e.key * 40).ms),
              ),
          const SizedBox(height: 24),
        ],
      );
    }

    // Skill matching: feature the opportunity that overlaps most with the
    // student's onboarding skills; fall back to the newest posting.
    final auth = context.read<AuthCubit>().state;
    final userSkills = auth is AuthAuthenticated
        ? auth.user.skills.map((s) => s.toLowerCase()).toSet()
        : <String>{};
    int matchScore(OpportunityModel o) =>
        o.skills.where((s) => userSkills.contains(s.toLowerCase())).length;

    var featured = items.first;
    var bestScore = matchScore(featured);
    for (final o in items) {
      final score = matchScore(o);
      if (score > bestScore) {
        featured = o;
        bestScore = score;
      }
    }
    final recent = items.where((o) => o.id != featured.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Recommended for you'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FeaturedOpportunityCard(
            opportunity: featured,
            matchedSkills: bestScore,
          ).animate().fadeIn(delay: 100.ms),
        ),
        const SizedBox(height: 28),
        if (recent.isNotEmpty)
          _sectionHeader(context, 'Recent opportunities'),
        ...recent.asMap().entries.map(
              (e) => OpportunityTile(opportunity: e.value)
                  .animate()
                  .fadeIn(delay: (140 + e.key * 40).ms),
            ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title,
      {String? actionLabel, VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Filter sheet ────────────────────────────────────────
  void _openFilters() {
    String commitment = _selectedCommitment;
    bool? paid = _paidFilter;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheet) {
            Widget chip(String label, bool selected, VoidCallback onTap) {
              return GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.grey100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? AppColors.white : AppColors.grey700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Filters',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  Text('Commitment',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.commitmentOptions
                        .map((c) => chip(
                            c,
                            commitment == c,
                            () => setSheet(() =>
                                commitment = commitment == c ? '' : c)))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('Payment',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      chip('Any', paid == null,
                          () => setSheet(() => paid = null)),
                      const SizedBox(width: 8),
                      chip('Paid', paid == true,
                          () => setSheet(() => paid = true)),
                      const SizedBox(width: 8),
                      chip('Unpaid', paid == false,
                          () => setSheet(() => paid = false)),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(sheetCtx);
                            _clearAll();
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(sheetCtx);
                            setState(() {
                              _selectedCommitment = commitment;
                              _paidFilter = paid;
                            });
                            final cubit = context.read<OpportunityCubit>();
                            cubit.filterByCommitment(commitment);
                            cubit.filterByPaid(paid);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Featured card: flat, solid primary ────────────────────
class FeaturedOpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;

  /// Number of the viewer's skills that this opportunity requires.
  /// When > 0 a "Matches your skills" tag is shown.
  final int matchedSkills;

  const FeaturedOpportunityCard({
    super.key,
    required this.opportunity,
    this.matchedSkills = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OpportunityDetailScreen(opportunity: opportunity),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: opportunity.startupLogoUrl != null
                        ? Image.network(opportunity.startupLogoUrl!,
                            fit: BoxFit.cover)
                        : const Icon(Icons.business_rounded,
                            color: AppColors.primary, size: 22),
                  ),
                  if (matchedSkills > 0) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Matches $matchedSkills of your skills',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  _BookmarkButton(
                    opportunityId: opportunity.id,
                    onPrimary: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                opportunity.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      opportunity.startupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (opportunity.startupVerified) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.verified,
                        color: AppColors.white.withValues(alpha: 0.9),
                        size: 14),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    opportunity.skills.take(3).map(_chip).toList(),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _meta(Icons.schedule_rounded, opportunity.commitment),
                  const SizedBox(width: 16),
                  _meta(
                    Icons.payments_outlined,
                    opportunity.isPaid ? 'Paid' : 'Volunteer',
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.white.withValues(alpha: 0.8), size: 15),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Compact opportunity tile ──────────────────────────────
class OpportunityTile extends StatelessWidget {
  final OpportunityModel opportunity;
  const OpportunityTile({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
              builder: (_) =>
                  OpportunityDetailScreen(opportunity: opportunity),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: opportunity.startupLogoUrl != null
                      ? Image.network(opportunity.startupLogoUrl!,
                          fit: BoxFit.cover)
                      : const Icon(Icons.business_rounded,
                          color: AppColors.primary, size: 23),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              opportunity.startupName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: AppColors.grey500),
                            ),
                          ),
                          if (opportunity.startupVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified,
                                color: AppColors.primary, size: 13),
                          ],
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          _miniTag(
                            opportunity.commitment,
                            AppColors.primarySurface,
                            AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          _miniTag(
                            opportunity.isPaid ? 'Paid' : 'Volunteer',
                            opportunity.isPaid
                                ? AppColors.successLight
                                : AppColors.grey100,
                            opportunity.isPaid
                                ? AppColors.success
                                : AppColors.grey600,
                          ),
                          if (opportunity.isClosingSoon) ...[
                            const SizedBox(width: 6),
                            _miniTag('Closing soon', AppColors.errorLight,
                                AppColors.error),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                _BookmarkButton(opportunityId: opportunity.id),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniTag(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────
class _BookmarkButton extends StatelessWidget {
  final String opportunityId;
  final bool onPrimary;

  const _BookmarkButton({required this.opportunityId, this.onPrimary = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BookmarkStore.instance,
      builder: (context, _) {
        final saved = BookmarkStore.instance.contains(opportunityId);
        return IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => BookmarkStore.instance.toggle(opportunityId),
          icon: Icon(
            saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            size: 22,
            color: onPrimary
                ? AppColors.white
                : (saved ? AppColors.primary : AppColors.grey400),
          ),
        );
      },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final bool showDot;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.grey200),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: AppColors.grey800, size: 22),
              if (showDot)
                Positioned(
                  top: 11,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  final String type;
  final int colorIndex;
  const _Category(this.label, this.icon, this.type, this.colorIndex);
}

class _ShimmerHome extends StatelessWidget {
  const _ShimmerHome();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 190,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              3,
              (_) => Container(
                height: 84,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
