import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/auth_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _role = 'student';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          displayName: _nameCtrl.text.trim(),
          role: _role,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final route = _role == 'student' ? '/onboarding/student' : '/onboarding/startup';
          context.go(route);
        } else if (state is AuthError) {
          context.showSnack(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          title: const Text('Create Account'),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join ALU Nexus',
                style: Theme.of(context).textTheme.headlineLarge,
              ).animate().fadeIn(),
              const SizedBox(height: 8),
              Text(
                'Connect with the ALU startup ecosystem',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: AppColors.grey600),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 32),

              // Role Selector
              _RoleSelector(
                selected: _role,
                onChanged: (r) => setState(() => _role = r),
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 24),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Full Name',
                      hint: 'Your full name',
                      controller: _nameCtrl,
                      validator: (v) => AppValidators.minLength(v, 2, fieldName: 'Name'),
                      prefixIcon: const Icon(Icons.person_outlined),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'ALU Email',
                      hint: 'you@alustudent.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: AppValidators.aluEmail,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ).animate().fadeIn(delay: 250.ms),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Password',
                      controller: _passwordCtrl,
                      obscureText: true,
                      validator: AppValidators.password,
                      prefixIcon: const Icon(Icons.lock_outlined),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Confirm Password',
                      controller: _confirmCtrl,
                      obscureText: true,
                      validator: (v) => AppValidators.confirmPassword(v, _passwordCtrl.text),
                      prefixIcon: const Icon(Icons.lock_outlined),
                      textInputAction: TextInputAction.done,
                    ).animate().fadeIn(delay: 350.ms),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) => AppButtonFullWidth(
                        label: 'Create Account',
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
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

class _RoleSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _RoleSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('I am a...', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                icon: Icons.school_outlined,
                label: 'Student',
                subtitle: 'Looking for opportunities',
                isSelected: selected == 'student',
                onTap: () => onChanged('student'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RoleCard(
                icon: Icons.rocket_launch_outlined,
                label: 'Startup',
                subtitle: 'Building something great',
                isSelected: selected == 'startup',
                onTap: () => onChanged('startup'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.07) : AppColors.grey50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.grey200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.grey500,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.grey900,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.grey500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
