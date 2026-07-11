import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/application_model.dart';
import '../cubit/application_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../opportunities/data/models/opportunity_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class ApplyScreen extends StatefulWidget {
  final OpportunityModel opportunity;

  const ApplyScreen({super.key, required this.opportunity});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();

  @override
  void dispose() {
    _coverLetterCtrl.dispose();
    _portfolioCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    final app = ApplicationModel(
      id: '',
      opportunityId: widget.opportunity.id,
      opportunityTitle: widget.opportunity.title,
      startupId: widget.opportunity.startupId,
      startupName: widget.opportunity.startupName,
      startupLogoUrl: widget.opportunity.startupLogoUrl,
      applicantId: user.uid,
      applicantName: user.displayName,
      applicantEmail: user.email,
      applicantPhotoUrl: user.photoUrl,
      coverLetter: _coverLetterCtrl.text.trim(),
      portfolioUrl: _portfolioCtrl.text.trim().isEmpty ? null : _portfolioCtrl.text.trim(),
      status: 'pending',
      skills: widget.opportunity.skills,
      appliedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    context.read<ApplicationCubit>().submitApplication(app);
  }

  @override
  Widget build(BuildContext context) {
    final opp = widget.opportunity;
    return BlocListener<ApplicationCubit, ApplicationState>(
      listener: (context, state) {
        if (state is ApplicationSubmitted) {
          context.showSnack('Application submitted successfully!');
          Navigator.pop(context, true);
        } else if (state is ApplicationError) {
          context.showSnack(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text('Apply'),
          backgroundColor: AppColors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Opportunity summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.business, color: AppColors.grey500),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opp.title, style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            '${opp.startupName} · ${opp.commitment}',
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: AppColors.grey500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 28),
              Text(
                'Your Application',
                style: Theme.of(context).textTheme.headlineSmall,
              ).animate().fadeIn(delay: 50.ms),
              const SizedBox(height: 4),
              Text(
                'Make it personal — startups read every application.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.grey500),
              ).animate().fadeIn(delay: 80.ms),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Cover Letter',
                      hint: 'Tell them why you\'re excited about this opportunity, what you\'ll bring to the team, and any relevant experience...',
                      controller: _coverLetterCtrl,
                      maxLines: 10,
                      maxLength: 2000,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Cover letter is required';
                        if (v.trim().length < 100) return 'Please write at least 100 characters';
                        return null;
                      },
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Portfolio / GitHub / LinkedIn URL (optional)',
                      hint: 'Share links to your work',
                      controller: _portfolioCtrl,
                      keyboardType: TextInputType.url,
                      prefixIcon: const Icon(Icons.link),
                    ).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tips_and_updates_outlined, color: AppColors.info, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tip: Mention specific skills from the job description and how you\'ve used them.',
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.info),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 180.ms),
                    const SizedBox(height: 32),
                    BlocBuilder<ApplicationCubit, ApplicationState>(
                      builder: (context, state) => AppButtonFullWidth(
                        label: 'Submit Application',
                        icon: Icons.send_outlined,
                        isLoading: state is ApplicationSubmitting,
                        onPressed: _submit,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 16),
                    Text(
                      'By applying you agree that your profile information will be shared with ${opp.startupName}.',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.grey500),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 220.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
