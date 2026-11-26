abstract class MyProjectState {}

class MyProjectInitial extends MyProjectState {}

class MyProjectLoading extends MyProjectState {}

class MyProjectSuccess extends MyProjectState {}

class MyProjectError extends MyProjectState {
  final String errorMessage;

  MyProjectError(this.errorMessage);
}