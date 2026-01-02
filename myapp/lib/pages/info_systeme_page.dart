import 'package:flutter/material.dart';
import 'weather.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class InfoSystemePage extends StatefulWidget {
  final String? systemId;

  const InfoSystemePage({super.key, this.systemId});

  @override
  State<InfoSystemePage> createState() => _InfoSystemePageState();
}

class _InfoSystemePageState extends State<InfoSystemePage> {
  Map<String, dynamic>? _metrics;
  Map<String, dynamic>? _weatherData = {};
  Map<String, dynamic>? _systemData = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.systemId != null) {
      _loadMetrics();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMetrics() async {
    if (widget.systemId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await StorageService.getToken();
      final metrics = await ApiService.getSystemMetrics(widget.systemId!, token: token);
      final systemData = await ApiService.getSystem(widget.systemId!, token: token);
      
      setState(() {
        _metrics = metrics['metrics'] as Map<String, dynamic>?;
        _systemData = systemData;
      });

      // Load weather based on system location
      if (systemData['latitude'] != null && systemData['longitude'] != null) {
        _loadWeather(systemData['latitude'], systemData['longitude']);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading metrics: $e');
      setState(() {
        _error = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWeather(double? lat, double? lon) async {
    if (lat == null || lon == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch weather from backend API based on system location
      final weather = await ApiService.getWeather(
        latitude: lat,
        longitude: lon,
      );
      
      setState(() {
        _weatherData = {
          'temperature': (weather['temperature'] as num?)?.toInt() ?? 26,
          'max': (weather['max'] as num?)?.toInt() ?? 28,
          'min': (weather['min'] as num?)?.toInt() ?? 24,
          'feels_like': (weather['feels_like'] as num?)?.toInt() ?? 31,
          'condition': weather['condition']?.toString() ?? 'Nuageux',
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading weather: $e');
      // Fallback to default values if API fails
      setState(() {
        _weatherData = {
          'temperature': 26,
          'max': 28,
          'min': 24,
          'feels_like': 31,
          'condition': 'Nuageux',
        };
        _isLoading = false;
      });
    }
  }

  String _extractValue(String? value) {
    if (value == null) return '0';
    final match = RegExp(r'[\d.]+').firstMatch(value);
    return match?.group(0) ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadMetrics,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4A6B3E),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              "Infos sur le système",
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    "en ligne",
                    style: TextStyle(
                      color: Color(0xFFB8FFB2),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 14),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeatherPage()),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA2C392), Color(0xFF8FB77B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Maintenant", style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 6),
                        Text(
                          "${_weatherData?['temperature'] ?? 26}°",
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Max: ${_weatherData?['max'] ?? 28}°   Min: ${_weatherData?['min'] ?? 24}°"),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("${_weatherData?['condition'] ?? 'Nuageux'}", style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text("Ressenti : ${_weatherData?['feels_like'] ?? 31}°"),
                        const SizedBox(height: 4),
                        Image.asset(
                          'assets/icons/cloud_sun.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.cloud, size: 60),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: _buildSmallCard(
                          icon: Icons.electric_bolt,
                          title: "Puissance actuelle",
                          value: _extractValue(_metrics?['current_power']?.toString()),
                          unit: "kW",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        fit: FlexFit.tight,
                        child: _buildSmallCard(
                          icon: Icons.battery_charging_full,
                          title: "Énergie du jour",
                          value: _extractValue(_metrics?['daily_energy']?.toString()),
                          unit: "kWh",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: _buildSmallCard(
                          icon: Icons.speed,
                          title: "Efficacité",
                          value: _extractValue(_metrics?['efficiency']?.toString()),
                          unit: "%",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        fit: FlexFit.tight,
                        child: _buildSmallCard(
                          icon: Icons.water_drop,
                          title: "Débit total",
                          value: _extractValue(_metrics?['total_flow']?.toString()),
                          unit: "m³",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF4A6B3E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    double height = 120,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(77, 207, 243, 190),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

