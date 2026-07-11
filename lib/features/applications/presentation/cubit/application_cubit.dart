import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/application_model.dart';
import '../../data/repositories/application_repository.dart';

part 'application_state.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  final ApplicationRepository _repo;
  StreamSubscription<List<ApplicationModel>>? _sub;

  ApplicationCubit(this._repo) : super(const ApplicationInitial());

  void loadStudentApplications(String studentId) {
    _sub?.cancel();
    emit(const ApplicationLoading());
    _sub = _repo.getStudentApplications(studentId).listen(
          (list) => emit(ApplicationLoaded(list)),
          onError: (e) => emit(ApplicationError(e.toString())),
        );
  }

  void loadStartupApplications(String startupId) {
    _sub?.cancel();
    emit(const ApplicationLoading());
    _sub = _repo.getStartupApplications(startupId).listen(
          (list) => emit(ApplicationLoaded(list)),
          onError: (e) => emit(ApplicationError(e.toString())),
        );
  }

  Future<void> submitApplication(ApplicationModel app) async {
    emit(const ApplicationSubmitting());
    try {
      final submitted = await _repo.submitApplication(app);
      emit(ApplicationSubmitted(submitted));
    } catch (e) {
      final msg = e.toString().contains('already applied')
          ? 'You have already applied for this opportunity.'
          : 'Failed to submit application. Please try again.';
      emit(ApplicationError(msg));
    }
  }

  Future<void> updateStatus(
    String appId,
    String status, {
    String? note,
    DateTime? interviewDate,
  }) async {
    try {
      await _repo.updateApplicationStatus(
        appId, status, note: note, interviewDate: interviewDate,
      );
    } catch (e) {
      emit(ApplicationError(e.toString()));
    }
  }

  Future<void> withdraw(String appId) async {
    try {
      await _repo.withdrawApplication(appId);
    } catch (e) {
      emit(ApplicationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
