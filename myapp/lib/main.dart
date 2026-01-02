// Unified main.dart - integrates all pages from the group project
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import all pages
import 'pages/splashpage.dart';
import 'pages/loginpage.dart';
import 'pages/inscription.dart';
import 'pages/passwordoublie.dart';
import 'pages/verifcodepage.dart';
import 'pages/resetpassword.dart';
import 'pages/home.dart';
import 'pages/system_detail_page.dart';
import 'pages/info_systeme_page.dart';
import 'pages/weather.dart';
import 'pages/profile_page.dart';
import 'pages/manage_systems_page.dart';
import 'pages/contact_us_page.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Solar PUMP',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const HomePageWrapper(),
      },
    );
  }
}

// Wrapper for HomePage that manages state
class HomePageWrapper extends StatefulWidget {
  const HomePageWrapper({super.key});

  @override
  State<HomePageWrapper> createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper> {
  List<HomeSystem> systems = [];
  List<AlertItem> alerts = [];
  bool _isLoading = true;
  String? _userName;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = await StorageService.getUserId();
      final token = await StorageService.getToken();

      if (userId == null || token == null) {
        setState(() {
          _error = 'Not logged in';
          _isLoading = false;
        });
        return;
      }

      // Load user profile for name
      try {
        final userData = await ApiService.getUserProfile(userId, token: token);
        _userName = userData['name'] as String?;
      } catch (e) {
        print('Error loading user name: $e');
      }

      // Load systems
      final systemsList = await ApiService.getSystems(userId, token: token);
      systems = systemsList.map((sys) {
        final metrics = sys['metrics'] as Map<String, dynamic>? ?? {};
        return HomeSystem(
          id: sys['id'] as String? ?? '',
          name: sys['name'] as String? ?? 'Unknown',
          currentPower: _extractValue(metrics['current_power']?.toString() ?? '0 W'),
          dailyEnergy: _extractValue(metrics['daily_energy']?.toString() ?? '0 kWh'),
          efficiency: _extractValue(metrics['efficiency']?.toString() ?? '0%'),
          totalFlow: _extractValue(metrics['total_flow']?.toString() ?? '0 L/min'),
        );
      }).toList();

      // Load alerts
      final alertsList = await ApiService.getUserAlerts(userId, token: token);
      alerts = alertsList.map((alert) {
        return AlertItem(
          id: alert['id'] as String? ?? '',
          title: alert['title'] as String? ?? 'Alert',
          subtitle: alert['subtitle'] as String?,
        );
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading home data: $e');
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  String _extractValue(String value) {
    // Extract numeric value from strings like "5.2 kW" -> "5.2"
    final match = RegExp(r'[\d.]+').firstMatch(value);
    return match?.group(0) ?? '0';
  }

  void _onSystemClick(HomeSystem system) async {
    // Fetch real metrics from backend
    try {
      final token = await StorageService.getToken();
      final metrics = await ApiService.getSystemMetrics(system.id, token: token);
      final metricsData = metrics['metrics'] as Map<String, dynamic>? ?? {};

      final detailSystem = DetailSystem(
        currentPower: _extractValue(metricsData['current_power']?.toString() ?? '0 W'),
        dailyEnergy: _extractValue(metricsData['daily_energy']?.toString() ?? '0 kWh'),
        efficiency: _extractValue(metricsData['efficiency']?.toString() ?? '0%'),
        totalFlow: _extractValue(metricsData['total_flow']?.toString() ?? '0 L/min'),
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SystemDetailPage(
              system: detailSystem,
              systemId: system.id,
              onBack: () => Navigator.pop(context),
              onProfileClick: () {
                Navigator.pop(context);
                _onProfileClick();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  void _onAddSystem() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un système'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du système',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      try {
        final userId = await StorageService.getUserId();
        final token = await StorageService.getToken();

        if (userId == null || token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Non connecté')),
          );
          return;
        }

        await ApiService.createSystem(
          userId: userId,
          name: nameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          token: token,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Système ajouté avec succès!')),
        );

        // Reload data
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _onProfileClick() {
    // Navigate to ProfilePage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePageWrapper(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return HomePage(
      systems: systems,
      alerts: alerts,
      userName: _userName ?? 'Utilisateur',
      onSystemClick: _onSystemClick,
      onProfileClick: _onProfileClick,
      onAddSystem: _onAddSystem,
      onRefresh: _loadData,
    );
  }
}

// Wrapper for ProfilePage that handles navigation
class ProfilePageWrapper extends StatelessWidget {
  const ProfilePageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      onManageSystems: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ManageSystemsPage(),
          ),
        );
      },
      onServices: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ContactUsPage(),
          ),
        );
      },
      onHome: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePageWrapper(),
          ),
        );
      },
    );
  }
}
