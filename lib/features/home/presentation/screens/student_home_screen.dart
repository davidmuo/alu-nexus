import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../notifications/presentation/cubit/notification_cubit.dart';
import '../../../opportunities/presentation/screens/opportunity_feed_screen.dart';
import '../../../startups/presentation/screens/startup_directory_screen.dart';
import '../../../applications/presentation/screens/application_tracker_screen.dart';
import '../../../profile/presentation/screens/student_profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final int initialTab;
  const StudentHomeScreen({super.key, this.initialTab = 0});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  late int _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotifications());
  }

  void _loadNotifications() {
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    context.read<NotificationCubit>().loadNotifications(user.uid);
  }

  final _tabs = const [
    OpportunityFeedScreen(),
    StartupDirectoryScreen(),
    ApplicationTrackerScreen(),
    StudentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _tabs),
      bottomNavigationBar: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, notifState) {
          final unread = notifState is NotificationLoaded ? notifState.unreadCount : 0;
          return BottomNavigationBar(
            currentIndex: _tab,
            onTap: (i) => setState(() => _tab = i),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore_rounded),
                label: 'Startups',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.assignment_outlined),
                ),
                activeIcon: const Icon(Icons.assignment_rounded),
                label: 'Applications',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}
