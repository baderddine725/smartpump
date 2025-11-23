part of 'pump_error_bloc.dart';

abstract class PumpErrorState extends Equatable {
  const PumpErrorState();

  @override
  List<Object> get props => [];
}

class PumpErrorInitial extends PumpErrorState {}

class PumpErrorLoadInProgress extends PumpErrorState {}

class PumpErrorLoadSuccess extends PumpErrorState {
  final List<PumpError> pumpErrors;

  const PumpErrorLoadSuccess({required this.pumpErrors});

  @override
  List<Object> get props => [pumpErrors];
}

class PumpErrorLoadFailure extends PumpErrorState {
  final String error;

  const PumpErrorLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}

