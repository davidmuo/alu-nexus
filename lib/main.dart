import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/bookmark_store.dart';
import 'core/theme/app_theme.dart';
import 'core/demo/demo_cubits.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/opportunities/data/repositories/opportunity_repository.dart';
import 'features/opportunities/presentation/cubit/opportunity_cubit.dart';
import 'features/applications/data/repositories/application_repository.dart';
import 'features/applications/presentation/cubit/application_cubit.dart';
import 'features/startups/data/repositories/startup_repository.dart';
import 'features/startups/presentation/cubit/startup_cubit.dart';
import 'features/notifications/presentation/cubit/notification_cubit.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';

/// Demo mode serves in-memory data so the app runs without a Firebase
/// project. Set to `false` after running `flutterfire configure` to switch
/// every repository to live Firebase Auth + Firestore.
const bool kDemoMode = false;

/// When running in live mode, connect to the local Firebase Emulator Suite
/// (firebase emulators:start) instead of production Firebase.
/// For a physical Android device run: adb reverse tcp:9099 tcp:9099
/// and adb reverse tcp:8080 tcp:8080 so localhost reaches the host machine.
const bool kUseEmulators = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await BookmarkStore.instance.init();

  if (!kDemoMode) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kUseEmulators) {
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    }
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AluNexusApp());
}

class AluNexusApp extends StatefulWidget {
  const AluNexusApp({super.key});

  @override
  State<AluNexusApp> createState() => _AluNexusAppState();
}

class _AluNexusAppState extends State<AluNexusApp> {
  late final AuthCubit _authCubit;
  late final OpportunityCubit _opportunityCubit;
  late final ApplicationCubit _applicationCubit;
  late final StartupCubit _startupCubit;
  late final NotificationCubit _notificationCubit;

  @override
  void initState() {
    super.initState();
    if (kDemoMode) {
      _authCubit = DemoAuthCubit();
      _opportunityCubit = DemoOpportunityCubit();
      _applicationCubit = DemoApplicationCubit();
      _startupCubit = DemoStartupCubit();
      _notificationCubit = DemoNotificationCubit();
    } else {
      // Live mode — real Firebase-backed repositories
      _authCubit = AuthCubit(AuthRepository());
      _opportunityCubit = OpportunityCubit(OpportunityRepository());
      _applicationCubit = ApplicationCubit(ApplicationRepository());
      _startupCubit = StartupCubit(StartupRepository());
      _notificationCubit = NotificationCubit();
    }
  }

  @override
  void dispose() {
    _authCubit.close();
    _opportunityCubit.close();
    _applicationCubit.close();
    _startupCubit.close();
    _notificationCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _opportunityCubit),
        BlocProvider.value(value: _applicationCubit),
        BlocProvider.value(value: _startupCubit),
        BlocProvider.value(value: _notificationCubit),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        bloc: _authCubit,
        builder: (context, _) {
          final router = AppRouter.create(_authCubit);
          return MaterialApp.router(
            title: 'ALU Nexus',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: router,
            builder: (context, child) {
              if (kDemoMode) {
                return Stack(
                  children: [
                    child!,
                    Positioned(
                      top: 0,
                      right: 0,
                      child: SafeArea(
                        child: Container(
                          margin: const EdgeInsets.only(top: 6, right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xB30F172A),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'DEMO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return child!;
            },
          );
        },
      ),
    );
  }
}
