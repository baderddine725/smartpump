import 'package:smartpump/data/models/pump/pump_status.dart';

class Site {
  final String siteId;
  final String siteName;
  final String location;
  final int numberOfPumps;
  final DateTime installationDate;
  final double totalInvestment;
  final double monthlySavings;
  final double performanceRate;
  final List<PumpStatusModel> pumps;

  Site({
    required this.siteId,
    required this.siteName,
    required this.location,
    required this.numberOfPumps,
    required this.installationDate,
    required this.totalInvestment,
    required this.monthlySavings,
    required this.performanceRate,
    required this.pumps,
  });

  double get roi => (monthlySavings * 12) / totalInvestment;
  int get operationalDays => DateTime.now().difference(installationDate).inDays;

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      siteId: json['siteId'],
      siteName: json['siteName'],
      location: json['location'],
      numberOfPumps: json['numberOfPumps'],
      installationDate: DateTime.parse(json['installationDate']),
      totalInvestment: json['totalInvestment'].toDouble(),
      monthlySavings: json['monthlySavings'].toDouble(),
      performanceRate: json['performanceRate'].toDouble(),
      pumps: (json['pumps'] as List?)
              ?.map((p) => PumpStatusModel.fromJson(p))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'siteId': siteId,
      'siteName': siteName,
      'location': location,
      'numberOfPumps': numberOfPumps,
      'installationDate': installationDate.toIso8601String(),
      'totalInvestment': totalInvestment,
      'monthlySavings': monthlySavings,
      'performanceRate': performanceRate,
      'pumps': pumps.map((p) => p.toJson()).toList(),
    };
  }
}

