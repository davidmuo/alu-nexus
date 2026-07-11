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
import '../../../../core/widgets/app_button.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final OpportunityModel opportunity;

  const OpportunityDetailScreen({super.key, required this.opportunity});

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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Opportunity details'),
        centerTitle: true,
        actions: [
          ListenableBuilder(
            listenable: BookmarkStore.instance,
            builder: (context, _) {
              final saved = BookmarkStore.instance.contains(opp.id);
              return IconButton(
                icon: Icon(
                  saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: saved ? AppColors.primary : AppColors.grey700,
                ),
                onPressed: () => BookmarkStore.instance.toggle(opp.id),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identity block
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: opp.startupLogoUrl != null
                      ? Image.network(opp.startupLogoUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.business_rounded,
                          color: AppColors.primary, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opp.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(height: 1.25),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              opp.startupName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: AppColors.grey500),
                            ),
                          ),
                          if (opp.startupVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified,
                                color: AppColors.primary, size: 15),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(),
            const SizedBox(height: 18),
            // Skill chips
            if (opp.skills.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: opp.skills.asMap().entries.map((e) {
                  final i = e.key % AppColors.skillColors.length;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.skillColors[i],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.skillTextColors[i],
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 50.ms),
            const SizedBox(height: 24),
            // Meta rows
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _MetaRow(
                    icon: Icons.schedule_rounded,
                    label: '${opp.commitment} · ${opp.duration}',
                  ),
                  const SizedBox(height: 12),
                  _MetaRow(
                    icon: Icons.location_on_outlined,
                    label: opp.location,
                  ),
                  const SizedBox(height: 12),
                  _MetaRow(
                    icon: Icons.payments_outlined,
                    label: opp.isPaid
                        ? 'Paid${opp.compensation != null ? ' · ${opp.compensation}' : ''}'
                        : 'Unpaid · Volunteer',
                  ),
                  const SizedBox(height: 12),
                  _MetaRow(
                    icon: Icons.event_outlined,
                    label: 'Apply by ${_formatDate(opp.deadline)}',
                    highlight: opp.isClosingSoon,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 28),
            _Section(
              title: 'About this role',
              child: Text(
                opp.description,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: AppColors.grey700,
                      height: 1.6,
                    ),
              ),
            ).animate().fadeIn(delay: 150.ms),
            if (opp.responsibilities.isNotEmpty) ...[
              const SizedBox(height: 24),
              _Section(
                title: 'What you\'ll do',
                child: Column(
                  children: opp.responsibilities
                      .map((r) => _BulletItem(text: r))
                      .toList(),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],
            if (opp.requirements.isNotEmpty) ...[
              const SizedBox(height: 24),
              _Section(
                title: 'What we\'re looking for',
                child: Column(
                  children: opp.requirements
                      .map((r) => _BulletItem(text: r))
                      .toList(),
                ),
              ).animate().fadeIn(delay: 250.ms),
            ],
            if (opp.perks != null && opp.perks!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _Section(
                title: 'Perks & benefits',
                child: Text(
                  opp.perks!,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.grey700,
                        height: 1.6,
                      ),
                ),
              ).animate().fadeIn(delay: 300.ms),
            ],
            const SizedBox(height: 28),
            // Stats
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _Stat(value: '${opp.applicationCount}', label: 'Applicants'),
                  _statDivider(),
                  _Stat(value: '${opp.viewCount}', label: 'Views'),
                  _statDivider(),
                  _Stat(value: '${opp.maxApplicants}', label: 'Spots'),
                ],
              ),
            ).animate().fadeIn(delay: 350.ms),
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

  Widget _statDivider() =>
      Container(width: 1, height: 32, color: AppColors.grey200);

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _MetaRow({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.error : AppColors.grey700;
    return Row(
      children: [
        Icon(icon, size: 18, color: highlight ? AppColors.error : AppColors.grey500),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grey200)),
      ),
      child: hasApplied
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'Application submitted',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: AppColors.success,
                        ),
                  ),
                ],
              ),
            )
          : AppButtonFullWidth(
              label: opportunity.isExpired
                  ? 'This opportunity has closed'
                  : 'Apply now',
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
            ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.grey700,
                    height: 1.5,
                  ),
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
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: AppColors.grey900,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
