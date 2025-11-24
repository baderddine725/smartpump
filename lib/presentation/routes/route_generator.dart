import 'package:flutter/material.dart';
import 'package:smartpump/presentation/pages/entrepreneur/executive_dashboard.dart';
import 'package:smartpump/presentation/pages/farmer/farmer_home_screen.dart';
import 'package:smartpump/presentation/pages/technician/technician_dashboard.dart';
import 'package:smartpump/presentation/routes/app_router.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.farmerHome:
        return MaterialPageRoute(
            builder: (_) => FarmerHomeScreen(farmerId: '1'));
      case AppRoutes.technicianDashboard:
        return MaterialPageRoute(builder: (_) => TechnicianDashboardScreen());
      case AppRoutes.entrepreneurDashboard:
        return MaterialPageRoute(builder: (_) => const ExecutiveDashboardScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('Page not found')));
    }
  }
}
