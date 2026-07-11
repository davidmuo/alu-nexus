import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/startup_model.dart';
import '../../data/repositories/startup_repository.dart';

part 'startup_state.dart';

class StartupCubit extends Cubit<StartupState> {
  final StartupRepository _repo;
  StreamSubscription<List<StartupModel>>? _sub;
  StreamSubscription<StartupModel?>? _singleSub;

  StartupCubit(this._repo) : super(const StartupInitial());

  void loadVerifiedStartups() {
    _sub?.cancel();
    emit(const StartupLoading());
    _sub = _repo.getVerifiedStartups().listen(
          (list) => emit(StartupsLoaded(list)),
          onError: (e) => emit(StartupError(e.toString())),
        );
  }

  void loadAllStartups() {
    _sub?.cancel();
    emit(const StartupLoading());
    _sub = _repo.getAllStartups().listen(
          (list) => emit(StartupsLoaded(list)),
          onError: (e) => emit(StartupError(e.toString())),
        );
  }

  void watchStartup(String id) {
    _singleSub?.cancel();
    emit(const StartupLoading());
    _singleSub = _repo.watchStartup(id).listen(
          (startup) => startup != null
              ? emit(StartupDetailLoaded(startup))
              : emit(const StartupError('Startup not found')),
          onError: (e) => emit(StartupError(e.toString())),
        );
  }

  Future<void> createStartup(StartupModel startup) async {
    emit(const StartupLoading());
    try {
      final created = await _repo.createStartup(startup);
      emit(StartupDetailLoaded(created));
    } catch (e) {
      emit(StartupError(e.toString()));
    }
  }

  Future<void> verifyStartup(
    String id, {
    required bool approved,
    String? note,
    String? adminId,
  }) async {
    try {
      await _repo.verifyStartup(id, approved: approved, note: note, adminId: adminId);
    } catch (e) {
      emit(StartupError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _singleSub?.cancel();
    return super.close();
  }
}
