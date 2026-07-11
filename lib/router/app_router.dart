import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/onboarding/presentation/screens/student_onboarding_screen.dart';
import '../features/onboarding/presentation/screens/startup_onboarding_screen.dart';
import '../features/home/presentation/screens/student_home_screen.dart';
import '../features/home/presentation/screens/startup_home_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/opportunities/presentation/screens/bookmarks_screen.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';

class AppRouter {
  static GoRouter create(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: _AuthNotifier(authCubit),
      redirect: (context, state) {
        final authState = authCubit.state;
        final onAuthPage = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/';

        if (authState is AuthInitial) return '/';
        if (authState is AuthUnauthenticated && !onAuthPage) return '/login';

        if (authState is AuthAuthenticated) {
          if (!authState.user.isOnboardingComplete) {
            final target = authState.user.isStudent
                ? '/onboarding/student'
                : '/onboarding/startup';
            if (state.matchedLocation != target) return target;
          } else if (onAuthPage) {
            return '/home';
          }
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(
          path: '/register',
          builder: (_, __) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/onboarding/student',
          builder: (_, __) => const StudentOnboardingScreen(),
        ),
        GoRoute(
          path: '/onboarding/startup',
          builder: (_, __) => const StartupOnboardingScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            final authState = context.read<AuthCubit>().state;
            if (authState is AuthAuthenticated) {
              if (authState.user.isAdmin) {
                return const AdminDashboardScreen();
              }
              if (authState.user.isStartup) {
                return const StartupHomeScreen();
              }
            }
            return const StudentHomeScreen();
          },
        ),
        GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/bookmarks',
          builder: (_, __) => const BookmarksScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const _ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (_, __) => const AdminDashboardScreen(),
        ),
      ],
    );
  }
}

class _AuthNotifier extends ChangeNotifier {
  final AuthCubit _cubit;
  _AuthNotifier(this._cubit) {
    _cubit.stream.listen((_) => notifyListeners());
  }
}

class _ForgotPasswordScreen extends StatefulWidget {
  const _ForgotPasswordScreen();
  @override
  State<_ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<_ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mark_email_read_outlined, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text('Reset link sent!', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Check your ALU email inbox for a password reset link.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Forgot Password', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your ALU email to receive a reset link.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ALU Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                context.read<AuthCubit>().sendPasswordReset(_emailCtrl.text.trim());
                                setState(() => _sent = true);
                              },
                        child: state is AuthLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Send Reset Link'),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }
}
