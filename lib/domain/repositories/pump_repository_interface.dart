import '../entities/pump_status.dart';

abstract class PumpRepositoryInterface {
  Future<PumpStatus> getPumpStatus(String pumpId);
  Future<void> startPump(String pumpId);
  Future<void> stopPump(String pumpId);
  Future<List<PumpStatus>> getAllPumpsStatus();
}
