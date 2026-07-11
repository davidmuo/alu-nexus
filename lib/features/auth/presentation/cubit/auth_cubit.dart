import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/app_user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;
  StreamSubscription<AppUser?>? _authSub;

  AuthCubit(this._repo) : super(const AuthInitial()) {
    _listenToAuth();
  }

  void _listenToAuth() {
    _authSub = _repo.authStateChanges.listen(
      (user) {
        if (user == null) {
          emit(const AuthUnauthenticated());
        } else {
          emit(AuthAuthenticated(user));
        }
      },
      onError: (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      emit(AuthAuthenticated(user));
    } on Exception catch (e) {
      debugPrint('signUp failed: $e');
      emit(AuthError(_parseError(e.toString())));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.signInWithEmail(email: email, password: password);
      emit(AuthAuthenticated(user));
    } on Exception catch (e) {
      debugPrint('signIn failed: $e');
      emit(AuthError(_parseError(e.toString())));
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    emit(const AuthUnauthenticated());
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _repo.sendPasswordReset(email);
      emit(const AuthPasswordResetSent());
    } on Exception catch (e) {
      emit(AuthError(_parseError(e.toString())));
    }
  }

  Future<void> completeOnboarding(Map<String, dynamic> profileData) async {
    final current = state;
    if (current is! AuthAuthenticated) return;
    emit(const AuthLoading());
    try {
      final user = await _repo.completeOnboarding(current.user.uid, profileData);
      emit(AuthAuthenticated(user));
    } on Exception catch (e) {
      emit(AuthError(_parseError(e.toString())));
    }
  }

  String _parseError(String raw) {
    if (raw.contains('email-already-in-use')) return 'This email is already registered.';
    if (raw.contains('wrong-password')) return 'Incorrect password.';
    if (raw.contains('user-not-found')) return 'No account found with this email.';
    if (raw.contains('weak-password')) return 'Password is too weak.';
    if (raw.contains('network-request-failed')) return 'No internet connection.';
    if (raw.contains('too-many-requests')) return 'Too many attempts. Try again later.';
    return 'Something went wrong. Please try again.';
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
