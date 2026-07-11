import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/opportunity_model.dart';
import '../../data/repositories/opportunity_repository.dart';
import '../../../applications/presentation/screens/apply_screen.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../applications/data/repositories/application_repository.dart';
import '../../../../core/services/bookmark_store.dart';
import '../../../../core/theme/app_colors.dart';

/// Dark, color-blocked detail screen: black canvas, the feed card's color
/// as the identity block, white content sections.
class OpportunityDetailScreen extends StatefulWidget {
  final OpportunityModel opportunity;
  final Color accentColor;

  const OpportunityDetailScreen({
    super.key,
    required this.opportunity,
    this.accentColor = AppColors.yellow,
  });

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  bool _hasApplied = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    OpportunityRepository().incrementViewCount(widget.opportunity.id);
    final applied = await ApplicationRepository()
        .hasApplied(user.uid, widget.opportunity.id);
    if (mounted) {
      setState(() {
        _hasApplied = applied;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final opp = widget.opportunity;
    final accent = widget.accentColor;
    final onAccent = AppColors.onCard(accent);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        title: const Text(
          'Opportunity details',
          style: TextStyle(color: AppColors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Identity block in the card's color ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: onAccent == AppColors.black
                              ? AppColors.black
                              : AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: opp.startupLogoUrl != null
                            ? Image.network(opp.startupLogoUrl!,
                                fit: BoxFit.cover)
                            : Icon(
                                Icons.business_rounded,
                                color: onAccent == AppColors.black
                                    ? accent
                                    : accent,
                                size: 24,
                              ),
                      ),
                      const Spacer(),
                      ListenableBuilder(
                        listenable: BookmarkStore.instance,
                        builder: (context, _) {
                          final saved =
                              BookmarkStore.instance.contains(opp.id);
                          return IconButton(
                            onPressed: () =>
                                BookmarkStore.instance.toggle(opp.id),
                            icon: Icon(
                              saved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: onAccent,
                              size: 26,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    opp.title,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      color: onAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          opp.startupName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            color: onAccent.withValues(alpha: 0.75),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (opp.startupVerified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified,
                            color: onAccent.withValues(alpha: 0.85),
                            size: 15),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        opp.isPaid
                            ? (opp.compensation ?? 'Paid')
                            : 'Volunteer role',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          color: onAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Posted ${_ago(opp.createdAt)}',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          color: onAccent.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 12),
            // ── Tag pills row ──
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _darkPill(Icons.schedule_rounded, opp.commitment),
                _darkPill(Icons.hourglass_bottom_rounded, opp.duration),
                _darkPill(Icons.location_on_outlined, opp.location),
                _darkPill(
                  Icons.event_outlined,
                  'Apply by ${_date(opp.deadline)}',
                  highlight: opp.isClosingSoon,
                ),
              ],
            ).animate().fadeIn(delay: 60.ms),
            const SizedBox(height: 12),
            // ── Content sections ──
            _whiteCard(
              title: 'About this role',
              child: Text(
                opp.description,
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  color: AppColors.grey700,
                  fontSize: 14.5,
                  height: 1.6,
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),
            if (opp.responsibilities.isNotEmpty) ...[
              const SizedBox(height: 12),
              _whiteCard(
                title: 'What you\'ll do',
                child: Column(
                  children: opp.responsibilities
                      .map((r) => _bullet(r, widget.accentColor))
                      .toList(),
                ),
              ).animate().fadeIn(delay: 140.ms),
            ],
            if (opp.requirements.isNotEmpty) ...[
              const SizedBox(height: 12),
              _whiteCard(
                title: 'Skills & requirements',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...opp.requirements
                        .map((r) => _bullet(r, widget.accentColor)),
                    if (opp.skills.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        opp.skills.join('  ·  '),
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tagPurple,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 180.ms),
            ],
            if (opp.perks != null && opp.perks!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _whiteCard(
                title: 'Perks & benefits',
                child: Text(
                  opp.perks!,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    color: AppColors.grey700,
                    fontSize: 14.5,
                    height: 1.6,
                  ),
                ),
              ).animate().fadeIn(delay: 220.ms),
            ],
            const SizedBox(height: 12),
            // ── Stats strip ──
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.grey900,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  _stat('${opp.applicationCount}', 'Applicants'),
                  _statDivider(),
                  _stat('${opp.viewCount}', 'Views'),
                  _statDivider(),
                  _stat('${opp.maxApplicants}', 'Spots'),
                ],
              ),
            ).animate().fadeIn(delay: 260.ms),
          ],
        ),
      ),
      bottomNavigationBar: _loading
          ? null
          : _BottomBar(
              hasApplied: _hasApplied,
              opportunity: opp,
              onApplied: () => setState(() => _hasApplied = true),
            ),
    );
  }

  Widget _darkPill(IconData icon, String label, {bool highlight = false}) {
    final color = highlight ? AppColors.red : AppColors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.withValues(alpha: 0.85)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Satoshi',
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _whiteCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _bullet(String text, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: accent == AppColors.yellow
                  ? AppColors.accentDark
                  : accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                color: AppColors.grey700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              color: AppColors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Satoshi',
              color: AppColors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(
      width: 1, height: 32, color: AppColors.white.withValues(alpha: 0.12));

  String _date(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _ago(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'just now';
  }
}

// ── Bottom bar: Save square + Apply pill ───────────────────
class _BottomBar extends StatelessWidget {
  final bool hasApplied;
  final OpportunityModel opportunity;
  final VoidCallback onApplied;

  const _BottomBar({
    required this.hasApplied,
    required this.opportunity,
    required this.onApplied,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      color: AppColors.black,
      child: hasApplied
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.grey900,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.success),
                  SizedBox(width: 8),
                  Text(
                    'Application submitted',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                ListenableBuilder(
                  listenable: BookmarkStore.instance,
                  builder: (context, _) {
                    final saved =
                        BookmarkStore.instance.contains(opportunity.id);
                    return Material(
                      color: AppColors.grey900,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () =>
                            BookmarkStore.instance.toggle(opportunity.id),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(
                            saved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: AppColors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.grey800,
                      ),
                      onPressed: opportunity.isExpired
                          ? null
                          : () async {
                              final applied = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ApplyScreen(opportunity: opportunity),
                                ),
                              );
                              if (applied == true) onApplied();
                            },
                      child: Text(
                        opportunity.isExpired
                            ? 'Opportunity closed'
                            : 'Apply Now  →',
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
