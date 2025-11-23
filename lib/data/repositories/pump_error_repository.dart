import '../../data/models/pump/pump_error.dart';

abstract class PumpErrorRepository {
  Future<List<PumpError>> getPumpErrors(String pumpId);
}

class PumpErrorRepositoryImpl implements PumpErrorRepository {
  @override
  Future<List<PumpError>> getPumpErrors(String pumpId) async {
    // Simulation d'un délai réseau
    await Future.delayed(const Duration(seconds: 1));
    
    // Données mock pour le développement
    return [
      PumpError(
        errorCode: 'E-0021',
        description: 'Surchauduleur détectée',
        severity: 'high',
        timestamp: DateTime.now(),
        possibleCauses: [
          'Ventilation obstruée',
          'Ambiance trop chaude',
          'Surcharge prolongée',
        ],
        solutions: [
          'Nettoyer les ventilateurs',
          'Vérifier la température ambiante',
          'Réduire la charge temporairement',
        ],
      ),
      PumpError(
        errorCode: 'E-0015',
        description: 'Faible débit d\'eau',
        severity: 'medium',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        possibleCauses: [
          'Niveau d\'eau bas',
          'Filtre obstrué',
          'Problème de pression',
        ],
        solutions: [
          'Vérifier le niveau d\'eau',
          'Nettoyer le filtre',
          'Vérifier la pression',
        ],
      ),
    ];
  }
}

