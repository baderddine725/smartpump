class PumpStatus {
  final String pumpId;
  final String pumpName;
  final bool isRunning;
  final double currentPower;
  final double waterFlow;
  final double voltage;
  final double current;
  final String status;
  final DateTime lastUpdate;
  final double dailyWaterConsumption;

  PumpStatus({
    required this.pumpId,
    required this.pumpName,
    required this.isRunning,
    required this.currentPower,
    required this.waterFlow,
    required this.voltage,
    required this.current,
    required this.status,
    required this.lastUpdate,
    required this.dailyWaterConsumption,
  });
}

