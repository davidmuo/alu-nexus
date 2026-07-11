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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (!state.user.isOnboardingComplete) {
            final route = state.user.isStudent ? '/onboarding/student' : '/onboarding/startup';
            context.go(route);
          } else {
            context.go('/home');
          }
        } else if (state is AuthError) {
          context.showSnack(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Logo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.hub_rounded, color: AppColors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ALU Nexus',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 48),
                Text(
                  'Welcome back!',
                  style: Theme.of(context).textTheme.displaySmall,
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 8),
                Text(
                  'Sign in with your ALU email',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: AppColors.grey600,
                      ),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'ALU Email',
                        hint: 'you@alustudent.com',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: AppValidators.aluEmail,
                        prefixIcon: const Icon(Icons.email_outlined),
                        textInputAction: TextInputAction.next,
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Password',
                        controller: _passwordCtrl,
                        obscureText: true,
                        validator: (v) => v?.isEmpty == true ? 'Password is required' : null,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        textInputAction: TextInputAction.done,
                      ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.1),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return AppButtonFullWidth(
                            label: 'Sign In',
                            isLoading: state is AuthLoading,
                            onPressed: _submit,
                          );
                        },
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or', style: Theme.of(context).textTheme.bodySmall),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => context.push('/register'),
                            child: const Text(
                              'Join ALU Nexus',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This platform is exclusively for ALU students and startups.',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: AppColors.info,
                              ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 450.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
