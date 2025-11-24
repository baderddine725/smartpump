import 'package:smartpump/domain/entities/pump_status.dart';
import 'package:smartpump/domain/repositories/pump_repository_interface.dart';

class GetPumpStatus {
  final PumpRepositoryInterface repository;

  GetPumpStatus(this.repository);

  Future<PumpStatus> execute(String pumpId) {
    return repository.getPumpStatus(pumpId);
  }
}