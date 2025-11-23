class PumpError {
  final String errorCode;
  final String description;
  final String severity; // 'high', 'medium', 'low'
  final DateTime timestamp;
  final List<String> possibleCauses;
  final List<String> solutions;

  PumpError({
    required this.errorCode,
    required this.description,
    required this.severity,
    required this.timestamp,
    required this.possibleCauses,
    required this.solutions,
  });

  factory PumpError.fromJson(Map<String, dynamic> json) {
    return PumpError(
      errorCode: json['errorCode'],
      description: json['description'],
      severity: json['severity'],
      timestamp: DateTime.parse(json['timestamp']),
      possibleCauses: List<String>.from(json['possibleCauses'] ?? []),
      solutions: List<String>.from(json['solutions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errorCode': errorCode,
      'description': description,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
      'possibleCauses': possibleCauses,
      'solutions': solutions,
    };
  }
}

