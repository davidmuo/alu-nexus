import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../startups/data/models/startup_model.dart';
import '../../../startups/data/repositories/startup_repository.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class StartupOnboardingScreen extends StatefulWidget {
  const StartupOnboardingScreen({super.key});

  @override
  State<StartupOnboardingScreen> createState() => _StartupOnboardingScreenState();
}

class _StartupOnboardingScreenState extends State<StartupOnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;
  bool _isSubmitting = false;

  // Fields
  final _nameCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _aluRegCtrl = TextEditingController();
  String _industry = 'Technology';
  String _stage = 'idea';
  final Set<String> _focusAreas = {};

  static const _industries = [
    'Technology', 'Education', 'Health & Wellness', 'Finance', 'Agriculture',
    'E-commerce', 'Media & Entertainment', 'Clean Energy', 'Social Impact',
    'Creative Arts', 'Consulting', 'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    _descCtrl.dispose();
    _websiteCtrl.dispose();
    _linkedinCtrl.dispose();
    _aluRegCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 2) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _page++);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    setState(() => _isSubmitting = true);
    try {
      final repo = StartupRepository();
      final startup = StartupModel(
        id: '',
        ownerId: user.uid,
        name: _nameCtrl.text.trim(),
        tagline: _taglineCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        industry: _industry,
        websiteUrl: _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
        linkedinUrl: _linkedinCtrl.text.trim().isEmpty ? null : _linkedinCtrl.text.trim(),
        verificationStatus: 'pending',
        teamSize: ['1-3'],
        focusAreas: _focusAreas.toList(),
        stage: _stage,
        foundedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        aluRegistrationNumber: _aluRegCtrl.text.trim().isEmpty ? null : _aluRegCtrl.text.trim(),
      );
      await repo.createStartup(startup);

      if (!mounted) return;
      await context.read<AuthCubit>().completeOnboarding({
        'hasStartup': true,
      });
    } catch (e) {
      if (!mounted) return;
      context.showSnack('Failed to submit. Please try again.', isError: true);
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.user.isOnboardingComplete) {
          context.go('/home');
        } else if (state is AuthError) {
          context.showSnack(state.message, isError: true);
          setState(() => _isSubmitting = false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.hub_rounded, color: AppColors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'ALU Nexus',
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const Spacer(),
                        Text('${_page + 1}/3',
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.grey500)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: List.generate(
                        3,
                        (i) => Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 4,
                            decoration: BoxDecoration(
                              color: i <= _page ? AppColors.accent : AppColors.grey200,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _StartupPage1(
                      nameCtrl: _nameCtrl,
                      taglineCtrl: _taglineCtrl,
                      descCtrl: _descCtrl,
                      industry: _industry,
                      industries: _industries,
                      onIndustryChanged: (v) => setState(() => _industry = v!),
                    ),
                    _StartupPage2(
                      stage: _stage,
                      focusAreas: _focusAreas,
                      onStageChanged: (s) => setState(() => _stage = s),
                      onToggleFocus: (s) => setState(() {
                        if (_focusAreas.contains(s)) {
                          _focusAreas.remove(s);
                        } else {
                          _focusAreas.add(s);
                        }
                      }),
                    ),
                    _StartupPage3(
                      websiteCtrl: _websiteCtrl,
                      linkedinCtrl: _linkedinCtrl,
                      aluRegCtrl: _aluRegCtrl,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AppButtonFullWidth(
                  label: _page < 2 ? 'Continue' : 'Submit for Verification',
                  icon: _page < 2 ? Icons.arrow_forward : Icons.verified_outlined,
                  isLoading: _isSubmitting,
                  onPressed: _next,
                  backgroundColor: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartupPage1 extends StatelessWidget {
  final TextEditingController nameCtrl, taglineCtrl, descCtrl;
  final String industry;
  final List<String> industries;
  final ValueChanged<String?> onIndustryChanged;

  const _StartupPage1({
    required this.nameCtrl,
    required this.taglineCtrl,
    required this.descCtrl,
    required this.industry,
    required this.industries,
    required this.onIndustryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Register your startup', style: Theme.of(context).textTheme.headlineMedium).animate().fadeIn(),
          const SizedBox(height: 4),
          Text(
            'Tell us about what you\'re building',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.grey500),
          ).animate().fadeIn(delay: 50.ms),
          const SizedBox(height: 28),
          AppTextField(
            label: 'Startup Name',
            hint: 'e.g., NexEd Solutions',
            controller: nameCtrl,
            prefixIcon: const Icon(Icons.rocket_launch_outlined),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Tagline',
            hint: 'One sentence that describes your startup',
            controller: taglineCtrl,
            maxLength: 100,
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Description',
            hint: 'Describe what problem you solve, your vision, and what you\'ve built so far...',
            controller: descCtrl,
            maxLines: 5,
            maxLength: 1000,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: industry,
            decoration: const InputDecoration(
              labelText: 'Industry',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: industries.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: onIndustryChanged,
          ).animate().fadeIn(delay: 250.ms),
        ],
      ),
    );
  }
}

class _StartupPage2 extends StatelessWidget {
  final String stage;
  final Set<String> focusAreas;
  final ValueChanged<String> onStageChanged;
  final ValueChanged<String> onToggleFocus;

  static const _stages = [
    ('idea', 'Idea Stage', 'Exploring the concept'),
    ('mvp', 'MVP', 'Built first version'),
    ('growth', 'Growth', 'Have users/traction'),
    ('scaling', 'Scaling', 'Expanding rapidly'),
  ];

  const _StartupPage2({
    required this.stage,
    required this.focusAreas,
    required this.onStageChanged,
    required this.onToggleFocus,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Startup stage & needs', style: Theme.of(context).textTheme.headlineMedium).animate().fadeIn(),
          const SizedBox(height: 4),
          Text(
            'This helps students understand your context',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: 28),
          Text('Current Stage', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ..._stages.map((s) {
            final isSelected = stage == s.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onStageChanged(s.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.07) : AppColors.grey50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.grey200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : AppColors.grey300,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.$2, style: Theme.of(context).textTheme.titleSmall),
                          Text(s.$3, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          Text('What roles do you need?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.opportunityTypes.map((area) {
              final isSelected = focusAreas.contains(area);
              return GestureDetector(
                onTap: () => onToggleFocus(area),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent.withValues(alpha: 0.15) : AppColors.grey100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.grey200,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    area,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.accentDark : AppColors.grey700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StartupPage3 extends StatelessWidget {
  final TextEditingController websiteCtrl, linkedinCtrl, aluRegCtrl;

  const _StartupPage3({
    required this.websiteCtrl,
    required this.linkedinCtrl,
    required this.aluRegCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verification & Links', style: Theme.of(context).textTheme.headlineMedium).animate().fadeIn(),
          const SizedBox(height: 4),
          Text(
            'Help us verify your startup is part of ALU',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Verification Process',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.warning),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your startup will be reviewed by ALU administrators. Only startups founded or co-founded by ALU students or alumni are eligible. Verification typically takes 1–3 business days.',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.grey700),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),
          AppTextField(
            label: 'ALU Registration / Cohort Number (optional)',
            hint: 'e.g., ALU-2024-CS-042',
            controller: aluRegCtrl,
            prefixIcon: const Icon(Icons.badge_outlined),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Website URL (optional)',
            hint: 'https://yourstartup.com',
            controller: websiteCtrl,
            keyboardType: TextInputType.url,
            prefixIcon: const Icon(Icons.language),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          AppTextField(
            label: 'LinkedIn Page (optional)',
            hint: 'linkedin.com/company/yourstartup',
            controller: linkedinCtrl,
            keyboardType: TextInputType.url,
            prefixIcon: const Icon(Icons.link),
          ).animate().fadeIn(delay: 250.ms),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can post opportunities and build your profile while verification is in progress.',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.success),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}
