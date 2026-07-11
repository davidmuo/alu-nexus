import 'dart:async';
import 'demo_data.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/opportunities/data/models/opportunity_model.dart';
import '../../features/opportunities/data/repositories/opportunity_repository.dart';
import '../../features/opportunities/presentation/cubit/opportunity_cubit.dart';
import '../../features/applications/data/models/application_model.dart';
import '../../features/applications/data/repositories/application_repository.dart';
import '../../features/applications/presentation/cubit/application_cubit.dart';
import '../../features/startups/data/models/startup_model.dart';
import '../../features/startups/data/repositories/startup_repository.dart';
import '../../features/startups/presentation/cubit/startup_cubit.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';
import '../../features/notifications/data/models/notification_model.dart';

// ─── Demo AuthRepository ─────────────────────────────────────────
class _DemoAuthRepository extends AuthRepository {
  static final _user = AppUser(
    uid: 'demo-student-1',
    email: 'demo@alustudent.com',
    displayName: 'Amara Diallo',
    role: 'student',
    skills: const ['Flutter', 'Dart', 'Firebase', 'Figma'],
    isOnboardingComplete: true,
    createdAt: DateTime(2024, 9, 1),
  );

  @override
  Stream<AppUser?> get authStateChanges =>
      Stream.value(_user).asBroadcastStream();

  @override
  Future<AppUser?> get currentUser async => _user;

  @override
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async => _user;

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return _user;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<AppUser> completeOnboarding(
    String uid,
    Map<String, dynamic> profileData,
  ) async => _user.copyWith(isOnboardingComplete: true);
}

// ─── Demo AuthCubit ──────────────────────────────────────────────
class DemoAuthCubit extends AuthCubit {
  DemoAuthCubit() : super(_DemoAuthRepository());
}

// ─── Demo OpportunityRepository ─────────────────────────────────
class _DemoOpportunityRepository extends OpportunityRepository {
  List<OpportunityModel> _opps = List.from(DemoData.opportunities);

  @override
  Future<OpportunityModel> createOpportunity(OpportunityModel opp) async {
    _opps = [opp, ..._opps];
    return opp;
  }

  @override
  Stream<List<OpportunityModel>> getActiveOpportunities({
    String? type,
    String? commitment,
    String? searchQuery,
    bool? isPaid,
  }) {
    var list = _opps.where((o) => o.isActive).toList();
    if (type != null && type.isNotEmpty) {
      list = list.where((o) => o.type == type).toList();
    }
    if (commitment != null && commitment.isNotEmpty) {
      list = list.where((o) => o.commitment == commitment).toList();
    }
    if (isPaid != null) {
      list = list.where((o) => o.isPaid == isPaid).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((o) =>
          o.title.toLowerCase().contains(q) ||
          o.startupName.toLowerCase().contains(q) ||
          o.description.toLowerCase().contains(q) ||
          o.skills.any((s) => s.toLowerCase().contains(q))).toList();
    }
    return Stream.value(list);
  }

  @override
  Stream<List<OpportunityModel>> getStartupOpportunities(String startupId) =>
      Stream.value(_opps.where((o) => o.startupId == startupId).toList());

  @override
  Future<OpportunityModel?> getById(String id) async =>
      _opps.firstWhere((o) => o.id == id, orElse: () => _opps.first);

  @override
  Future<void> incrementViewCount(String id) async {}

  @override
  Future<void> closeOpportunity(String id) async {}

  @override
  Future<List<OpportunityModel>> getRecommendedOpportunities(
    List<String> userSkills,
  ) async => _opps.take(3).toList();
}

// ─── Demo OpportunityCubit ───────────────────────────────────────
class DemoOpportunityCubit extends OpportunityCubit {
  DemoOpportunityCubit() : super(_DemoOpportunityRepository());
}

// ─── Demo ApplicationRepository ─────────────────────────────────
class _DemoApplicationRepository extends ApplicationRepository {
  List<ApplicationModel> _apps = List.from(DemoData.myApplications);

  @override
  Future<ApplicationModel> submitApplication(ApplicationModel app) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _apps = [app, ..._apps];
    return app;
  }

  @override
  Stream<List<ApplicationModel>> getStudentApplications(String studentId) =>
      Stream.value(_apps);

  @override
  Stream<List<ApplicationModel>> getStartupApplications(String startupId) =>
      Stream.value([]);

  @override
  Stream<List<ApplicationModel>> getOpportunityApplications(
    String opportunityId,
  ) =>
      Stream.value(
        _apps.where((a) => a.opportunityId == opportunityId).toList(),
      );

  @override
  Future<void> updateApplicationStatus(
    String appId,
    String status, {
    String? note,
    DateTime? interviewDate,
  }) async {
    _apps = _apps
        .map((a) => a.id == appId ? a.copyWith(status: status, statusNote: note) : a)
        .toList();
  }

  @override
  Future<void> withdrawApplication(String appId) =>
      updateApplicationStatus(appId, 'withdrawn');

  @override
  Future<bool> hasApplied(String studentId, String opportunityId) async =>
      _apps.any((a) => a.opportunityId == opportunityId);
}

// ─── Demo ApplicationCubit ───────────────────────────────────────
class DemoApplicationCubit extends ApplicationCubit {
  DemoApplicationCubit() : super(_DemoApplicationRepository());
}

// ─── Demo StartupRepository ──────────────────────────────────────
class _DemoStartupRepository extends StartupRepository {
  final List<StartupModel> _startups = List.from(DemoData.startups);

  @override
  Future<StartupModel> createStartup(StartupModel startup) async => startup;

  @override
  Future<StartupModel?> getStartupById(String id) async =>
      _startups.firstWhere((s) => s.id == id, orElse: () => _startups.first);

  @override
  Future<StartupModel?> getStartupByOwner(String ownerId) async =>
      _startups.first;

  @override
  Stream<List<StartupModel>> getVerifiedStartups() =>
      Stream.value(_startups.where((s) => s.isVerified).toList());

  @override
  Stream<List<StartupModel>> getAllStartups() => Stream.value(_startups);

  @override
  Stream<StartupModel?> watchStartup(String id) =>
      Stream.value(_startups.firstWhere(
        (s) => s.id == id,
        orElse: () => _startups.first,
      ));

  @override
  Future<void> updateStartup(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> verifyStartup(
    String startupId, {
    required bool approved,
    String? note,
    String? adminId,
  }) async {}
}

// ─── Demo StartupCubit ───────────────────────────────────────────
class DemoStartupCubit extends StartupCubit {
  DemoStartupCubit() : super(_DemoStartupRepository());
}

// ─── Demo NotificationCubit ──────────────────────────────────────
class DemoNotificationCubit extends NotificationCubit {
  List<NotificationModel> _notifs = List.from(DemoData.notifications);

  DemoNotificationCubit() : super();

  @override
  void loadNotifications(String userId) {
    final unread = _notifs.where((n) => !n.isRead).length;
    emit(NotificationLoaded(_notifs, unread));
  }

  @override
  Future<void> markAllRead(String userId) async {
    _notifs = _notifs
        .map((n) => NotificationModel(
              id: n.id,
              userId: n.userId,
              title: n.title,
              body: n.body,
              type: n.type,
              referenceId: n.referenceId,
              isRead: true,
              createdAt: n.createdAt,
            ))
        .toList();
    emit(NotificationLoaded(_notifs, 0));
  }

  @override
  Future<void> markRead(String notifId) async {
    _notifs = _notifs
        .map((n) => n.id == notifId
            ? NotificationModel(
                id: n.id,
                userId: n.userId,
                title: n.title,
                body: n.body,
                type: n.type,
                referenceId: n.referenceId,
                isRead: true,
                createdAt: n.createdAt,
              )
            : n)
        .toList();
    final unread = _notifs.where((n) => !n.isRead).length;
    emit(NotificationLoaded(_notifs, unread));
  }
}
