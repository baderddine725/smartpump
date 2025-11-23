import 'package:equatable/equatable.dart';

abstract class PumpStatusEvent extends Equatable {
  const PumpStatusEvent();

  @override
  List<Object> get props => [];
}

class PumpStatusRequested extends PumpStatusEvent {
  final String pumpId;

  const PumpStatusRequested({required this.pumpId});

  @override
  List<Object> get props => [pumpId];
}

class PumpStartRequested extends PumpStatusEvent {
  final String pumpId;

  const PumpStartRequested({required this.pumpId});

  @override
  List<Object> get props => [pumpId];
}

class PumpStopRequested extends PumpStatusEvent {
  final String pumpId;

  const PumpStopRequested({required this.pumpId});

  @override
  List<Object> get props => [pumpId];
}

class AllPumpsStatusRequested extends PumpStatusEvent {}