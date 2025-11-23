// core/errors/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Erreur réseau']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erreur serveur']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de cache']);
}

class ModbusFailure extends Failure {
  const ModbusFailure([super.message = 'Erreur Modbus']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = "Accès non autorisé"]);
}
