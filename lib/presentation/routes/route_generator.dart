import 'package:flutter/material.dart';
import '../pages/farmer_home_screen.dart';
import '../pages/technician_dashboard_screen.dart';
import '../pages/entrepreneur_dashboard_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.farmerHome:
        return MaterialPageRoute(
            builder: (_) => FarmerHomeScreen(farmerId: '1'));
      case AppRoutes.technicianDashboard:
        return MaterialPageRoute(builder: (_) => TechnicianDashboardScreen());
      case AppRoutes.entrepreneurDashboard:
        return MaterialPageRoute(builder: (_) => EntrepreneurDashboardScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('Page not found')));
    }
  }
}
