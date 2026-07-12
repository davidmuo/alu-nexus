import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_wordmark.dart';

class StudentOnboardingScreen extends StatefulWidget {
  const StudentOnboardingScreen({super.key});

  @override
  State<StudentOnboardingScreen> createState() => _StudentOnboardingScreenState();
}

class _StudentOnboardingScreenState extends State<StudentOnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  // Page 1: About
  final _bioCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  String? _program;
  int _year = 1;

  // Page 2: Skills
  final Set<String> _skills = {};

  // Page 3: Interests
  final Set<String> _interests = {};
  bool _openToRemote = true;
  bool _openToPaid = false;

  @override
  void dispose() {
    _bioCtrl.dispose();
    _linkedinCtrl.dispose();
    _portfolioCtrl.dispose();
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
      _complete();
    }
  }

  void _complete() {
    final data = {
      'bio': _bioCtrl.text.trim(),
      'program': _program,
      'year': _year,
      'linkedinUrl': _linkedinCtrl.text.trim(),
      'portfolioUrl': _portfolioCtrl.text.trim(),
      'skills': _skills.toList(),
      'interests': _interests.toList(),
      'openToRemote': _openToRemote,
      'openToPaid': _openToPaid,
    };
    context.read<AuthCubit>().completeOnboarding(data);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.user.isOnboardingComplete) {
          context.go('/home');
        } else if (state is AuthError) {
          context.showSnack(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const AppWordmark(size: 20),
                        const Spacer(),
                        Text(
                          '${_page + 1}/3',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: AppColors.grey500,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Progress bar
                    Row(
                      children: List.generate(
                        3,
                        (i) => Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 4,
                            decoration: BoxDecoration(
                              color: i <= _page ? AppColors.primary : AppColors.grey200,
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
                    _Page1(
                      bioCtrl: _bioCtrl,
                      linkedinCtrl: _linkedinCtrl,
                      portfolioCtrl: _portfolioCtrl,
                      program: _program,
                      year: _year,
                      onProgramChanged: (v) => setState(() => _program = v),
                      onYearChanged: (v) => setState(() => _year = v),
                    ),
                    _Page2(
                      selected: _skills,
                      onToggle: (s) => setState(() {
                        if (_skills.contains(s)) {
                          _skills.remove(s);
                        } else {
                          _skills.add(s);
                        }
                      }),
                    ),
                    _Page3(
                      selected: _interests,
                      openToRemote: _openToRemote,
                      openToPaid: _openToPaid,
                      onToggleInterest: (s) => setState(() {
                        if (_interests.contains(s)) {
                          _interests.remove(s);
                        } else {
                          _interests.add(s);
                        }
                      }),
                      onRemoteChanged: (v) => setState(() => _openToRemote = v),
                      onPaidChanged: (v) => setState(() => _openToPaid = v),
                    ),
                  ],
                ),
              ),
              // Bottom button
              Padding(
                padding: const EdgeInsets.all(24),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) => AppButtonFullWidth(
                    label: _page < 2 ? 'Continue' : 'Complete Setup',
                    icon: _page < 2 ? Icons.arrow_forward : Icons.check,
                    isLoading: state is AuthLoading,
                    onPressed: _next,
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

class _Page1 extends StatelessWidget {
  final TextEditingController bioCtrl, linkedinCtrl, portfolioCtrl;
  final String? program;
  final int year;
  final ValueChanged<String?> onProgramChanged;
  final ValueChanged<int> onYearChanged;

  const _Page1({
    required this.bioCtrl,
    required this.linkedinCtrl,
    required this.portfolioCtrl,
    required this.program,
    required this.year,
    required this.onProgramChanged,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about yourself', style: Theme.of(context).textTheme.headlineMedium)
              .animate().fadeIn(),
          const SizedBox(height: 4),
          Text(
            'Help startups know who you are',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.grey500),
          ).animate().fadeIn(delay: 50.ms),
          const SizedBox(height: 28),
          DropdownButtonFormField<String>(
            initialValue: program,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Program',
              prefixIcon: Icon(Icons.school_outlined),
            ),
            items: AppConstants.aluPrograms
                .map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: onProgramChanged,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),
          Text('Year of Study', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: List.generate(4, (i) {
              final y = i + 1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => onYearChanged(y),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: year == y ? AppColors.primary : AppColors.grey100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Year $y',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: year == y ? AppColors.white : AppColors.grey700,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Bio',
            hint: 'Tell startups what makes you unique...',
            controller: bioCtrl,
            maxLines: 4,
            maxLength: 300,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          AppTextField(
            label: 'LinkedIn URL (optional)',
            hint: 'linkedin.com/in/yourname',
            controller: linkedinCtrl,
            keyboardType: TextInputType.url,
            prefixIcon: const Icon(Icons.link),
          ).animate().fadeIn(delay: 250.ms),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Portfolio/GitHub URL (optional)',
            hint: 'github.com/yourname',
            controller: portfolioCtrl,
            keyboardType: TextInputType.url,
            prefixIcon: const Icon(Icons.link),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _Page2 extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _Page2({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Skills', style: Theme.of(context).textTheme.headlineMedium)
              .animate().fadeIn(),
          const SizedBox(height: 4),
          Text(
            'Select skills to get matched with relevant opportunities',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.grey500),
          ).animate().fadeIn(delay: 50.ms),
          const SizedBox(height: 8),
          if (selected.isNotEmpty)
            Text(
              '${selected.length} selected',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.allSkills.map((skill) {
              final isSelected = selected.contains(skill);
              return GestureDetector(
                onTap: () => onToggle(skill),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.grey100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.grey200,
                    ),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.white : AppColors.grey700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 100.ms),
        ],
      ),
    );
  }
}

class _Page3 extends StatelessWidget {
  final Set<String> selected;
  final bool openToRemote;
  final bool openToPaid;
  final ValueChanged<String> onToggleInterest;
  final ValueChanged<bool> onRemoteChanged;
  final ValueChanged<bool> onPaidChanged;

  const _Page3({
    required this.selected,
    required this.openToRemote,
    required this.openToPaid,
    required this.onToggleInterest,
    required this.onRemoteChanged,
    required this.onPaidChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Preferences', style: Theme.of(context).textTheme.headlineMedium)
              .animate().fadeIn(),
          const SizedBox(height: 4),
          Text(
            'Help us surface the most relevant opportunities for you',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.grey500),
          ).animate().fadeIn(delay: 50.ms),
          const SizedBox(height: 28),
          Text('Roles I\'m interested in', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.opportunityTypes.map((type) {
              final isSelected = selected.contains(type);
              return GestureDetector(
                onTap: () => onToggleInterest(type),
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
                    type,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.accentDark : AppColors.grey700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 28),
          Text('Work preferences', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _PrefToggle(
            label: 'Open to remote work',
            subtitle: 'I can work from anywhere',
            value: openToRemote,
            onChanged: onRemoteChanged,
            icon: Icons.wifi_outlined,
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 12),
          _PrefToggle(
            label: 'Prefer paid opportunities',
            subtitle: 'Show paid internships first',
            value: openToPaid,
            onChanged: onPaidChanged,
            icon: Icons.attach_money,
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}

class _PrefToggle extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const _PrefToggle({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey500, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleSmall),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
