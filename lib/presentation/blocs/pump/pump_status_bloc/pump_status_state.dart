part of 'pump_status_bloc.dart';

abstract class PumpStatusState extends Equatable {
  const PumpStatusState();

  @override
  List<Object> get props => [];
}

class PumpStatusInitial extends PumpStatusState {}

class PumpStatusLoadInProgress extends PumpStatusState {}

class PumpStatusLoadSuccess extends PumpStatusState {
  final PumpStatus pumpStatus;

  const PumpStatusLoadSuccess({required this.pumpStatus});

  @override
  List<Object> get props => [pumpStatus];
}

class PumpStatusLoadFailure extends PumpStatusState {
  final String error;

  const PumpStatusLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class AllPumpsStatusLoadSuccess extends PumpStatusState {
  final List<PumpStatus> pumpsStatus;

  const AllPumpsStatusLoadSuccess({required this.pumpsStatus});

  @override
  List<Object> get props => [pumpsStatus];
}

class PumpOperationInProgress extends PumpStatusState {
  final String operation;

  const PumpOperationInProgress({required this.operation});

  @override
  List<Object> get props => [operation];
}

class PumpOperationSuccess extends PumpStatusState {
  final String message;

  const PumpOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class PumpOperationFailure extends PumpStatusState {
  final String error;

  const PumpOperationFailure({required this.error});

  @override
  List<Object> get props => [error];
}