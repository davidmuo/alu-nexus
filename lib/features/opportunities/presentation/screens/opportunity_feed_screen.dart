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

  /// Top pill tabs: 'discover', 'saved', or an opportunity type.
  String _tab = 'discover';
  String _selectedCommitment = '';
  bool? _paidFilter;

  static const _typeTabs = [
    ('Engineering', 'Software Development'),
    ('Design', 'UI/UX Design'),
    ('Marketing', 'Marketing'),
    ('Research', 'Research & Analysis'),
    ('Community', 'Community Management'),
    ('Business', 'Business Development'),
  ];

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

  void _selectTab(String tab) {
    setState(() => _tab = tab);
    final cubit = context.read<OpportunityCubit>();
    if (tab == 'discover' || tab == 'saved') {
      cubit.filterByType('');
    } else {
      cubit.filterByType(tab);
    }
  }

  void _clearAll() {
    setState(() {
      _searchCtrl.clear();
      _tab = 'discover';
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Text(
                  'Find\nOpportunities',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ).animate().fadeIn(duration: 250.ms),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _searchRow(context),
              ),
              const SizedBox(height: 18),
              _pillTabs(),
              const SizedBox(height: 18),
              _body(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header: greeting + bell + avatar ─────────────────────
  Widget _header(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final name = auth is AuthAuthenticated
        ? auth.user.displayName.split(' ').first
        : 'there';
    final photo = auth is AuthAuthenticated ? auth.user.photoUrl : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.black,
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
                      fontFamily: 'Satoshi',
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hello, $name',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: AppColors.grey600),
            ),
          ),
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final unread =
                  state is NotificationLoaded ? state.unreadCount : 0;
              return _RoundIconButton(
                icon: Icons.notifications_none_rounded,
                showDot: unread > 0,
                onTap: () => context.push('/notifications'),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Search + filter ──────────────────────────────────────
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
              hintText: 'Search for startup or role...',
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
              fillColor: AppColors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: AppColors.black,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _openFilters,
            child: SizedBox(
              width: 54,
              height: 54,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.tune_rounded,
                      color: AppColors.white, size: 22),
                  if (_selectedCommitment.isNotEmpty || _paidFilter != null)
                    Positioned(
                      top: 13,
                      right: 14,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.yellow,
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

  // ── Pill tabs: Discover / Saved / categories ─────────────
  Widget _pillTabs() {
    Widget pill(String label, String value) {
      final selected = _tab == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => _selectTab(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.black : AppColors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: selected ? AppColors.black : AppColors.grey200,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.grey700,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          pill('Discover', 'discover'),
          pill('Saved', 'saved'),
          ..._typeTabs.map((t) => pill(t.$1, t.$2)),
        ],
      ),
    ).animate().fadeIn(delay: 80.ms);
  }

  // ── Body ─────────────────────────────────────────────────
  Widget _body(BuildContext context) {
    return BlocBuilder<OpportunityCubit, OpportunityState>(
      builder: (context, state) {
        if (state is OpportunityLoading) return const _ShimmerFeed();
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
        if (state is! OpportunityLoaded) return const SizedBox.shrink();

        if (_tab == 'saved') {
          return ListenableBuilder(
            listenable: BookmarkStore.instance,
            builder: (context, _) {
              final saved = state.opportunities
                  .where((o) => BookmarkStore.instance.contains(o.id))
                  .toList();
              if (saved.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: EmptyStateWidget(
                    icon: Icons.bookmark_border_rounded,
                    title: 'Nothing saved yet',
                    subtitle: 'Tap the bookmark on any card to save it here',
                  ),
                );
              }
              return _cardList(context, saved);
            },
          );
        }

        if (state.opportunities.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 30),
            child: EmptyStateWidget(
              icon: Icons.search_off_rounded,
              title: 'No opportunities found',
              subtitle: 'Try adjusting your filters or search',
              actionLabel: 'Clear filters',
              onAction: _clearAll,
            ),
          );
        }

        // Rank the student's best skill match first on Discover.
        var items = state.opportunities;
        int bestMatch = 0;
        if (_tab == 'discover') {
          final auth = context.read<AuthCubit>().state;
          final skills = auth is AuthAuthenticated
              ? auth.user.skills.map((s) => s.toLowerCase()).toSet()
              : <String>{};
          int score(OpportunityModel o) => o.skills
              .where((s) => skills.contains(s.toLowerCase()))
              .length;
          items = List.of(state.opportunities)
            ..sort((a, b) => score(b).compareTo(score(a)));
          bestMatch = items.isEmpty ? 0 : score(items.first);
        }

        return _cardList(context, items, firstMatchCount: bestMatch);
      },
    );
  }

  Widget _cardList(BuildContext context, List<OpportunityModel> items,
      {int firstMatchCount = 0}) {
    return Column(
      children: [
        ...items.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: OpportunityCard(
                opportunity: e.value,
                color: AppColors.cardColors[e.key % AppColors.cardColors.length],
                matchedSkills: e.key == 0 ? firstMatchCount : 0,
              ).animate().fadeIn(delay: (e.key * 60).ms).slideY(
                    begin: 0.05,
                    end: 0,
                    duration: 250.ms,
                  ),
            )),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Filter sheet ─────────────────────────────────────────
  void _openFilters() {
    String commitment = _selectedCommitment;
    bool? paid = _paidFilter;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.black : AppColors.grey100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      color: selected ? AppColors.white : AppColors.grey700,
                      fontWeight: FontWeight.w700,
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
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Filters',
                      style: Theme.of(context).textTheme.headlineSmall),
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

// ── Color-blocked opportunity card ─────────────────────────
class OpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final Color color;
  final int matchedSkills;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.color = AppColors.primary,
    this.matchedSkills = 0,
  });

  @override
  Widget build(BuildContext context) {
    final fg = AppColors.onCard(color);
    final fgSoft = fg.withValues(alpha: 0.75);
    final overlay = fg.withValues(alpha: fg == AppColors.black ? 0.08 : 0.16);

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OpportunityDetailScreen(
              opportunity: opportunity,
              accentColor: color,
            ),
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
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: fg == AppColors.black
                          ? AppColors.black
                          : AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: opportunity.startupLogoUrl != null
                        ? Image.network(opportunity.startupLogoUrl!,
                            fit: BoxFit.cover)
                        : Icon(Icons.business_rounded,
                            color: fg == AppColors.black
                                ? AppColors.yellow
                                : color,
                            size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opportunity.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            color: fg,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                opportunity.startupName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  color: fgSoft,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (opportunity.startupVerified) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.verified, color: fgSoft, size: 14),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  _BookmarkButton(
                    opportunityId: opportunity.id,
                    color: fg,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (matchedSkills > 0)
                    _pill('★ Matches $matchedSkills skills', overlay, fg),
                  _pill(opportunity.commitment, overlay, fg),
                  _pill(opportunity.duration, overlay, fg),
                  _pill(opportunity.location, overlay, fg),
                  if (opportunity.isClosingSoon)
                    _pill('Closing soon', overlay, fg),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 11),
                    decoration: BoxDecoration(
                      color: fg == AppColors.black
                          ? AppColors.black
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'View',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        color: fg == AppColors.black
                            ? AppColors.white
                            : AppColors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        opportunity.isPaid
                            ? (opportunity.compensation ?? 'Paid')
                            : 'Volunteer',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          color: fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Posted ${_ago(opportunity.createdAt)}',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          color: fgSoft,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Satoshi',
          color: fg,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _ago(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'just now';
  }
}

// ── Shared small widgets ────────────────────────────────────
class _BookmarkButton extends StatelessWidget {
  final String opportunityId;
  final Color color;

  const _BookmarkButton({required this.opportunityId, required this.color});

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
            size: 24,
            color: color,
          ),
        );
      },
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final bool showDot;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: AppColors.grey900, size: 22),
              if (showDot)
                Positioned(
                  top: 11,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.red,
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

class _ShimmerFeed extends StatelessWidget {
  const _ShimmerFeed();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: List.generate(
            3,
            (_) => Container(
              height: 190,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
