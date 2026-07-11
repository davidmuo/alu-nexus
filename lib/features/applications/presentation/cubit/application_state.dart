part of 'application_cubit.dart';

abstract class ApplicationState extends Equatable {
  const ApplicationState();
  @override
  List<Object?> get props => [];
}

class ApplicationInitial extends ApplicationState {
  const ApplicationInitial();
}

class ApplicationLoading extends ApplicationState {
  const ApplicationLoading();
}

class ApplicationSubmitting extends ApplicationState {
  const ApplicationSubmitting();
}

class ApplicationLoaded extends ApplicationState {
  final List<ApplicationModel> applications;
  const ApplicationLoaded(this.applications);
  @override
  List<Object?> get props => [applications];
}

class ApplicationSubmitted extends ApplicationState {
  final ApplicationModel application;
  const ApplicationSubmitted(this.application);
  @override
  List<Object?> get props => [application];
}

class ApplicationError extends ApplicationState {
  final String message;
  const ApplicationError(this.message);
  @override
  List<Object?> get props => [message];
}
