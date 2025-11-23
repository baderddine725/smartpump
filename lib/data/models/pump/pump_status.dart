class PumpStatusModel {
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

  PumpStatusModel({
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

  factory PumpStatusModel.fromJson(Map<String, dynamic> json) {
    return PumpStatusModel(
      pumpId: json['pumpId'],
      pumpName: json['pumpName'],
      isRunning: json['isRunning'],
      currentPower: json['currentPower'].toDouble(),
      waterFlow: json['waterFlow'].toDouble(),
      voltage: json['voltage'].toDouble(),
      current: json['current'].toDouble(),
      status: json['status'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      dailyWaterConsumption: json['dailyWaterConsumption'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pumpId': pumpId,
      'pumpName': pumpName,
      'isRunning': isRunning,
      'currentPower': currentPower,
      'waterFlow': waterFlow,
      'voltage': voltage,
      'current': current,
      'status': status,
      'lastUpdate': lastUpdate.toIso8601String(),
      'dailyWaterConsumption': dailyWaterConsumption,
    };
  }

  // Méthode utilitaire pour l'interface agriculteur
  String get simplifiedStatus {
    if (!isRunning) return 'Arrêtée';
    if (status == 'error') return 'Problème détecté';
    if (waterFlow < 5) return 'Débit faible';
    return 'Fonctionne normalement';
  }
}