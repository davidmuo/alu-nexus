part of 'startup_cubit.dart';

abstract class StartupState extends Equatable {
  const StartupState();
  @override
  List<Object?> get props => [];
}

class StartupInitial extends StartupState {
  const StartupInitial();
}

class StartupLoading extends StartupState {
  const StartupLoading();
}

class StartupsLoaded extends StartupState {
  final List<StartupModel> startups;
  const StartupsLoaded(this.startups);
  @override
  List<Object?> get props => [startups];
}

class StartupDetailLoaded extends StartupState {
  final StartupModel startup;
  const StartupDetailLoaded(this.startup);
  @override
  List<Object?> get props => [startup];
}

class StartupError extends StartupState {
  final String message;
  const StartupError(this.message);
  @override
  List<Object?> get props => [message];
}
