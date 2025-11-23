import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/pump/pump_error.dart';
import '../../../../data/repositories/pump_error_repository.dart';

part 'pump_error_event.dart';
part 'pump_error_state.dart';

class PumpErrorBloc extends Bloc<PumpErrorEvent, PumpErrorState> {
  final PumpErrorRepository pumpErrorRepository;

  PumpErrorBloc({required this.pumpErrorRepository}) : super(PumpErrorInitial()) {
    on<PumpErrorRequested>(_onPumpErrorRequested);
  }

  Future<void> _onPumpErrorRequested(
    PumpErrorRequested event,
    Emitter<PumpErrorState> emit,
  ) async {
    emit(PumpErrorLoadInProgress());
    
    try {
      final pumpErrors = await pumpErrorRepository.getPumpErrors(event.pumpId);
      emit(PumpErrorLoadSuccess(pumpErrors: pumpErrors));
    } catch (error) {
      emit(PumpErrorLoadFailure(error: error.toString()));
    }
  }
}

