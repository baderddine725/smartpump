class DecisionAnalysis {
  final String decisionId;
  final String description;
  final List<DecisionOption> options;
  final Map<String, double> criteriaWeights;
  final DateTime analysisDate;
  final String recommendedOption;
  final double confidenceLevel;

  DecisionAnalysis({
    required this.decisionId,
    required this.description,
    required this.options,
    required this.criteriaWeights,
    required this.analysisDate,
    required this.recommendedOption,
    required this.confidenceLevel,
  });

  factory DecisionAnalysis.fromJson(Map<String, dynamic> json) {
    return DecisionAnalysis(
      decisionId: json['decisionId'],
      description: json['description'],
      options: (json['options'] as List)
          .map((option) => DecisionOption.fromJson(option))
          .toList(),
      criteriaWeights: Map<String, double>.from(json['criteriaWeights']),
      analysisDate: DateTime.parse(json['analysisDate']),
      recommendedOption: json['recommendedOption'],
      confidenceLevel: json['confidenceLevel'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'decisionId': decisionId,
      'description': description,
      'options': options.map((option) => option.toJson()).toList(),
      'criteriaWeights': criteriaWeights,
      'analysisDate': analysisDate.toIso8601String(),
      'recommendedOption': recommendedOption,
      'confidenceLevel': confidenceLevel,
    };
  }
}

class DecisionOption {
  final String optionId;
  final String name;
  final String description;
  final double estimatedCost;
  final double expectedROI;
  final Duration implementationTime;
  final Map<String, double> criteriaScores;
  final List<String> risks;
  final List<String> opportunities;

  DecisionOption({
    required this.optionId,
    required this.name,
    required this.description,
    required this.estimatedCost,
    required this.expectedROI,
    required this.implementationTime,
    required this.criteriaScores,
    required this.risks,
    required this.opportunities,
  });

  double calculateScore(Map<String, double> weights) {
    double totalScore = 0;
    criteriaScores.forEach((criterion, score) {
      totalScore += score * (weights[criterion] ?? 0);
    });
    return totalScore;
  }

  factory DecisionOption.fromJson(Map<String, dynamic> json) {
    return DecisionOption(
      optionId: json['optionId'],
      name: json['name'],
      description: json['description'],
      estimatedCost: json['estimatedCost'].toDouble(),
      expectedROI: json['expectedROI'].toDouble(),
      implementationTime: Duration(days: json['implementationTime']),
      criteriaScores: Map<String, double>.from(json['criteriaScores']),
      risks: List<String>.from(json['risks']),
      opportunities: List<String>.from(json['opportunities']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'optionId': optionId,
      'name': name,
      'description': description,
      'estimatedCost': estimatedCost,
      'expectedROI': expectedROI,
      'implementationTime': implementationTime.inDays,
      'criteriaScores': criteriaScores,
      'risks': risks,
      'opportunities': opportunities,
    };
  }
}

