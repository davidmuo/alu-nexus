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
        backgroundColor: AppColors.black,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.hub_rounded,
                    size: 28, color: AppColors.white),
              ).animate().fadeIn(duration: 400.ms).scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    curve: Curves.easeOut,
                  ),
              const SizedBox(height: 28),
              const Text(
                'Your next\nstartup experience\nstarts here',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  color: AppColors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ).animate().fadeIn(delay: 250.ms, duration: 500.ms).slideY(
                    begin: 0.08,
                    end: 0,
                  ),
              const SizedBox(height: 12),
              Text(
                'ALU Nexus — where ALU students meet\nstudent-led startups.',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  color: AppColors.white.withValues(alpha: 0.6),
                  fontSize: 15,
                  height: 1.45,
                ),
              ).animate().fadeIn(delay: 450.ms, duration: 500.ms),
              const SizedBox(height: 44),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
