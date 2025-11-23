import '../models/pump/pump_status.dart';
import '../../domain/entities/pump_status.dart';
import '../../domain/repositories/pump_repository_interface.dart';

class MockPumpRepository implements PumpRepositoryInterface {
  @override
  Future<PumpStatus> getPumpStatus(String pumpId) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final model = PumpStatusModel(
      pumpId: pumpId,
      pumpName: 'Pompe Nord',
      isRunning: true,
      currentPower: 2500.0,
      waterFlow: 12.5,
      voltage: 230.0,
      current: 10.8,
      status: 'normal',
      lastUpdate: DateTime.now(),
      dailyWaterConsumption: 12500.0,
    );

    return PumpStatus(
      pumpId: model.pumpId,
      pumpName: model.pumpName,
      isRunning: model.isRunning,
      currentPower: model.currentPower,
      waterFlow: model.waterFlow,
      voltage: model.voltage,
      current: model.current,
      status: model.status,
      lastUpdate: model.lastUpdate,
      dailyWaterConsumption: model.dailyWaterConsumption,
    );
  }

  @override
  Future<void> startPump(String pumpId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> stopPump(String pumpId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<List<PumpStatus>> getAllPumpsStatus() async {
    await Future.delayed(const Duration(seconds: 1));
    
    final pumps = [
      PumpStatusModel(
        pumpId: '1',
        pumpName: 'Pompe Nord',
        isRunning: true,
        currentPower: 2500.0,
        waterFlow: 12.5,
        voltage: 230.0,
        current: 10.8,
        status: 'normal',
        lastUpdate: DateTime.now(),
        dailyWaterConsumption: 12500.0,
      ),
      PumpStatusModel(
        pumpId: '2',
        pumpName: 'Pompe Sud',
        isRunning: false,
        currentPower: 0.0,
        waterFlow: 0.0,
        voltage: 0.0,
        current: 0.0,
        status: 'normal',
        lastUpdate: DateTime.now(),
        dailyWaterConsumption: 0.0,
      ),
    ];

    return pumps.map((model) => PumpStatus(
      pumpId: model.pumpId,
      pumpName: model.pumpName,
      isRunning: model.isRunning,
      currentPower: model.currentPower,
      waterFlow: model.waterFlow,
      voltage: model.voltage,
      current: model.current,
      status: model.status,
      lastUpdate: model.lastUpdate,
      dailyWaterConsumption: model.dailyWaterConsumption,
    )).toList();
  }
}

