part of 'pump_error_bloc.dart';

abstract class PumpErrorEvent extends Equatable {
  const PumpErrorEvent();

  @override
  List<Object> get props => [];
}

class PumpErrorRequested extends PumpErrorEvent {
  final String pumpId;

  const PumpErrorRequested({required this.pumpId});

  @override
  List<Object> get props => [pumpId];
}

