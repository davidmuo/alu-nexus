import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/opportunity_model.dart';
import '../cubit/opportunity_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../startups/data/repositories/startup_repository.dart';
import '../../../startups/data/models/startup_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class PostOpportunityScreen extends StatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _compensationCtrl = TextEditingController();
  final _locationCtrl = TextEditingController(text: 'Remote');
  final _perksCtrl = TextEditingController();

  String _type = AppConstants.opportunityTypes.first;
  String _commitment = AppConstants.commitmentOptions.first;
  String _duration = AppConstants.durationOptions[2];
  bool _isPaid = false;
  int _deadlineDays = 14;
  final Set<String> _skills = {};
  final List<TextEditingController> _respCtrl = [TextEditingController()];
  final List<TextEditingController> _reqCtrl = [TextEditingController()];
  bool _isSubmitting = false;
  StartupModel? _startup;

  @override
  void initState() {
    super.initState();
    _loadStartup();
  }

  Future<void> _loadStartup() async {
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    final startup = await StartupRepository().getStartupByOwner(user.uid);
    if (mounted) setState(() => _startup = startup);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _compensationCtrl.dispose();
    _locationCtrl.dispose();
    _perksCtrl.dispose();
    for (final c in _respCtrl) {
      c.dispose();
    }
    for (final c in _reqCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startup == null) {
      context.showSnack('Startup profile not found', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final opp = OpportunityModel(
        id: '',
        startupId: _startup!.id,
        startupName: _startup!.name,
        startupLogoUrl: _startup!.logoUrl,
        startupVerified: _startup!.isVerified,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        type: _type,
        skills: _skills.toList(),
        commitment: _commitment,
        duration: _duration,
        isPaid: _isPaid,
        compensation: _isPaid && _compensationCtrl.text.isNotEmpty
            ? _compensationCtrl.text.trim()
            : null,
        location: _locationCtrl.text.trim(),
        applicationDeadline: _deadlineDays,
        deadline: DateTime.now().add(Duration(days: _deadlineDays)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        responsibilities: _respCtrl.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
        requirements: _reqCtrl.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
        perks: _perksCtrl.text.trim().isEmpty ? null : _perksCtrl.text.trim(),
      );
      await context.read<OpportunityCubit>().createOpportunity(opp);
      if (!mounted) return;
      context.showSnack('Opportunity posted successfully!');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      context.showSnack('Failed to post opportunity', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Post Opportunity'),
        backgroundColor: AppColors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_startup != null && !_startup!.isVerified)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_outlined, color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your startup is pending verification. Posted opportunities will become visible to students once approved.',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.grey800),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),
              AppTextField(
                label: 'Role Title',
                hint: 'e.g., Flutter Developer Intern',
                controller: _titleCtrl,
                validator: (v) => v?.isEmpty == true ? 'Title is required' : null,
              ).animate().fadeIn(delay: 50.ms),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _type,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Role Category'),
                items: AppConstants.opportunityTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ).animate().fadeIn(delay: 80.ms),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                hint: 'Describe this role and what the intern will work on...',
                controller: _descCtrl,
                maxLines: 5,
                validator: (v) => v?.isEmpty == true ? 'Description is required' : null,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 24),
              _buildDynamicList(
                title: 'Responsibilities',
                controllers: _respCtrl,
                hint: 'e.g., Build and maintain mobile app features',
                onAdd: () => setState(() => _respCtrl.add(TextEditingController())),
                onRemove: (i) => setState(() {
                  _respCtrl[i].dispose();
                  _respCtrl.removeAt(i);
                }),
              ).animate().fadeIn(delay: 120.ms),
              const SizedBox(height: 20),
              _buildDynamicList(
                title: 'Requirements',
                controllers: _reqCtrl,
                hint: 'e.g., Experience with Dart/Flutter',
                onAdd: () => setState(() => _reqCtrl.add(TextEditingController())),
                onRemove: (i) => setState(() {
                  _reqCtrl[i].dispose();
                  _reqCtrl.removeAt(i);
                }),
              ).animate().fadeIn(delay: 140.ms),
              const SizedBox(height: 20),
              _SectionTitle(title: 'Skills Required'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: AppConstants.allSkills.take(24).map((skill) {
                  final isSelected = _skills.contains(skill);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (isSelected) {
                        _skills.remove(skill);
                      } else {
                        _skills.add(skill);
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.grey100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? AppColors.white : AppColors.grey700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 160.ms),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _commitment,
                      decoration: const InputDecoration(labelText: 'Commitment'),
                      items: AppConstants.commitmentOptions
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _commitment = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _duration,
                      decoration: const InputDecoration(labelText: 'Duration'),
                      items: AppConstants.durationOptions
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (v) => setState(() => _duration = v!),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 180.ms),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Location',
                hint: 'Remote / Kigali / Mauritius',
                controller: _locationCtrl,
                prefixIcon: const Icon(Icons.location_on_outlined),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              // Paid toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, color: AppColors.grey500),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Paid Opportunity', style: Theme.of(context).textTheme.titleSmall),
                          Text('Will interns receive compensation?',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isPaid,
                      onChanged: (v) => setState(() => _isPaid = v),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 220.ms),
              if (_isPaid) ...[
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Compensation Details',
                  hint: r'e.g., $200/month stipend',
                  controller: _compensationCtrl,
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                ).animate().fadeIn(),
              ],
              const SizedBox(height: 24),
              _SectionTitle(title: 'Application Deadline'),
              const SizedBox(height: 8),
              Text(
                '$_deadlineDays days from today',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Slider(
                value: _deadlineDays.toDouble(),
                min: 3,
                max: 60,
                divisions: 19,
                activeColor: AppColors.primary,
                label: '$_deadlineDays days',
                onChanged: (v) => setState(() => _deadlineDays = v.round()),
              ).animate().fadeIn(delay: 240.ms),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Perks & Benefits (optional)',
                hint: 'e.g., Certificate, mentorship, equity consideration...',
                controller: _perksCtrl,
                maxLines: 3,
              ).animate().fadeIn(delay: 260.ms),
              const SizedBox(height: 32),
              AppButtonFullWidth(
                label: 'Post Opportunity',
                icon: Icons.rocket_launch,
                isLoading: _isSubmitting,
                onPressed: _submit,
              ).animate().fadeIn(delay: 280.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicList({
    required String title,
    required List<TextEditingController> controllers,
    required String hint,
    required VoidCallback onAdd,
    required ValueChanged<int> onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title),
        const SizedBox(height: 10),
        ...controllers.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: e.value,
                      decoration: InputDecoration(hintText: hint),
                      maxLines: 2,
                      minLines: 1,
                    ),
                  ),
                  if (controllers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                      onPressed: () => onRemove(e.key),
                    ),
                ],
              ),
            )),
        TextButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: Text('Add ${title.toLowerCase().split(' ').first}'),
          onPressed: onAdd,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}
