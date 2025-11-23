class ROIAnalysis {
  final double investmentInitial;
  final double annualSavings;
  final double operationalCosts;
  final double annualROI;
  final double paybackPeriod; // en années
  final double npv; // Net Present Value
  final double irr; // Internal Rate of Return
  final Map<int, double> cashFlowProjection; // Projection 5 ans

  ROIAnalysis({
    required this.investmentInitial,
    required this.annualSavings,
    required this.operationalCosts,
    required this.annualROI,
    required this.paybackPeriod,
    required this.npv,
    required this.irr,
    required this.cashFlowProjection,
  });

  double get netAnnualSavings => annualSavings - operationalCosts;
  double get monthlyROI => annualROI / 12;

  factory ROIAnalysis.fromJson(Map<String, dynamic> json) {
    return ROIAnalysis(
      investmentInitial: json['investmentInitial'].toDouble(),
      annualSavings: json['annualSavings'].toDouble(),
      operationalCosts: json['operationalCosts'].toDouble(),
      annualROI: json['annualROI'].toDouble(),
      paybackPeriod: json['paybackPeriod'].toDouble(),
      npv: json['npv'].toDouble(),
      irr: json['irr'].toDouble(),
      cashFlowProjection: Map<int, double>.from(
        json['cashFlowProjection'].map((key, value) => MapEntry(int.parse(key), value.toDouble())),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'investmentInitial': investmentInitial,
      'annualSavings': annualSavings,
      'operationalCosts': operationalCosts,
      'annualROI': annualROI,
      'paybackPeriod': paybackPeriod,
      'npv': npv,
      'irr': irr,
      'cashFlowProjection': cashFlowProjection.map((key, value) => MapEntry(key.toString(), value)),
    };
  }
}

