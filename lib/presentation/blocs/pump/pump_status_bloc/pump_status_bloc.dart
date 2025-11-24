import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smartpump/domain/entities/pump_status.dart';
import 'package:smartpump/domain/repositories/pump_repository_interface.dart';

part 'pump_status_event.dart';
part 'pump_status_state.dart';

class PumpStatusBloc extends Bloc<PumpStatusEvent, PumpStatusState> {
  final PumpRepositoryInterface pumpRepository;

  PumpStatusBloc({required this.pumpRepository}) : super(PumpStatusInitial()) {
    on<PumpStatusRequested>(_onPumpStatusRequested);
    on<PumpStartRequested>(_onPumpStartRequested);
    on<PumpStopRequested>(_onPumpStopRequested);
    on<AllPumpsStatusRequested>(_onAllPumpsStatusRequested);
  }

  Future<void> _onPumpStatusRequested(
    PumpStatusRequested event,
    Emitter<PumpStatusState> emit,
  ) async {
    emit(PumpStatusLoadInProgress());
    try {
      final pumpStatus = await pumpRepository.getPumpStatus(event.pumpId);
      emit(PumpStatusLoadSuccess(pumpStatus: pumpStatus));
    } catch (error) {
      emit(PumpStatusLoadFailure(error: error.toString()));
    }
  }

  Future<void> _onPumpStartRequested(
    PumpStartRequested event,
    Emitter<PumpStatusState> emit,
  ) async {
    emit(PumpOperationInProgress(operation: 'Démarrage'));
    try {
      await pumpRepository.startPump(event.pumpId);
      emit(PumpOperationSuccess(message: 'Pompe démarrée avec succès'));
      add(PumpStatusRequested(pumpId: event.pumpId));
    } catch (error) {
      emit(PumpOperationFailure(error: error.toString()));
    }
  }

  Future<void> _onPumpStopRequested(
    PumpStopRequested event,
    Emitter<PumpStatusState> emit,
  ) async {
    emit(PumpOperationInProgress(operation: 'Arrêt'));
    try {
      await pumpRepository.stopPump(event.pumpId);
      emit(PumpOperationSuccess(message: 'Pompe arrêtée avec succès'));
      add(PumpStatusRequested(pumpId: event.pumpId));
    } catch (error) {
      emit(PumpOperationFailure(error: error.toString()));
    }
  }

  Future<void> _onAllPumpsStatusRequested(
    AllPumpsStatusRequested event,
    Emitter<PumpStatusState> emit,
  ) async {
    emit(PumpStatusLoadInProgress());
    try {
      final allPumpsStatus = await pumpRepository.getAllPumpsStatus();
      emit(AllPumpsStatusLoadSuccess(pumpsStatus: allPumpsStatus));
    } catch (error) {
      emit(PumpStatusLoadFailure(error: error.toString()));
    }
  }
}