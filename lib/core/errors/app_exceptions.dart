// core/errors/appexceptions.dart
class AppException implements Exception {
  final String message;
  final int? code;
  AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class NotFoundException extends AppException {
  NotFoundException([super.message = "Non trouvé"]);
}

class TimeoutException extends AppException {
  TimeoutException([super.message = "Délai d’attente dépassé"]);
}

class BadRequestException extends AppException {
  BadRequestException([super.message = "Requête invalide"]);
}
