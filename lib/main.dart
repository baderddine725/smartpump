// lib/main.dart
import 'package:flutter/material.dart';
import 'home.dart' as home;
import 'system_detail_page.dart' as detail;
import 'profile_page.dart' as profile;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Systems Demo',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePageWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePageWrapper extends StatefulWidget {
  const HomePageWrapper({super.key});

  @override
  State<HomePageWrapper> createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper> {
  late List<home.System> systems;
  final List<home.AlertItem> alerts = [
    home.AlertItem(id: 'a1', title: 'Overcurrent', subtitle: 'Phase 2 high'),
    home.AlertItem(id: 'a2', title: 'Low Flow'),
  ];

  @override
  void initState() {
    super.initState();
    systems = [
      home.System.mock('1', 'System A'),
      home.System.mock('2', 'System B'),
    ];
  }

  void _onSystemClick(home.System system) {
    // Navigation vers SystemDetailPage
    final detailSystem = _systemToDetailSystem(system);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => detail.SystemDetailPage(
          system: detailSystem,
          onBack: () {},
          onProfileClick: () {},
        ),
      ),
    );
  }

  void _onAddSystem() {
    // Dialog pour ajouter un nouveau système
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un système'),
        content: const Text('Nouveau système ajouté avec succès!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                systems.add(home.System.mock(
                  '${systems.length + 1}',
                  'System ${String.fromCharCode(65 + systems.length)}',
                ));
              });
            },
            child: const Text('Ajouter'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _onProfileClick() {
    // Navigation vers ProfilePage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const profile.ProfilePage(),
      ),
    );
  }

  detail.System _systemToDetailSystem(home.System s) {
    return detail.System(
      currentPower: s.currentPower,
      dailyEnergy: s.dailyEnergy,
      efficiency: s.efficiency,
      totalFlow: s.totalFlow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return home.HomePage(
      systems: systems,
      alerts: alerts,
      onSystemClick: _onSystemClick,
      onProfileClick: _onProfileClick,
      onAddSystem: _onAddSystem,
    );
  }
}
