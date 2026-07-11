import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../cubit/auth_cubit.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), _checkAuth);
  }

  void _checkAuth() {
    if (_hasNavigated || !mounted) return;
    final state = context.read<AuthCubit>().state;
    _navigate(state);
  }

  void _navigate(AuthState state) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    if (state is AuthAuthenticated) {
      if (!state.user.isOnboardingComplete) {
        final route = state.user.isStudent ? '/onboarding/student' : '/onboarding/startup';
        context.go(route);
      } else {
        context.go('/home');
      }
    } else if (state is AuthUnauthenticated) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthUnauthenticated) {
          Future.delayed(const Duration(milliseconds: 500), () => _navigate(state));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.hub_rounded,
                    size: 42, color: AppColors.white),
              ).animate().fadeIn(duration: 400.ms).scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    curve: Curves.easeOut,
                  ),
              const SizedBox(height: 24),
              Text(
                'ALU Nexus',
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: AppColors.grey900,
                      fontWeight: FontWeight.w800,
                    ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              const SizedBox(height: 8),
              Text(
                'Where ALU students meet startups',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: AppColors.grey500,
                    ),
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
              const SizedBox(height: 48),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ).animate().fadeIn(delay: 900.ms),
            ],
          ),
        ),
      ),
    );
  }
}
