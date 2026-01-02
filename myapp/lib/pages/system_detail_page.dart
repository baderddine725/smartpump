import 'package:flutter/material.dart';
import 'weather.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// Renamed System to DetailSystem to avoid conflicts
class DetailSystem {
  final String currentPower;
  final String dailyEnergy;
  final String efficiency;
  final String totalFlow;

  DetailSystem({
    required this.currentPower,
    required this.dailyEnergy,
    required this.efficiency,
    required this.totalFlow,
  });
}

class SystemDetailPage extends StatefulWidget {
  final DetailSystem system;
  final String? systemId;
  final VoidCallback onBack;
  final VoidCallback onProfileClick;

  const SystemDetailPage({
    super.key,
    required this.system,
    this.systemId,
    required this.onBack,
    required this.onProfileClick,
  });

  @override
  State<SystemDetailPage> createState() => _SystemDetailPageState();
}

class _SystemDetailPageState extends State<SystemDetailPage> {
  Map<String, dynamic>? _systemData;
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadSystemData();
  }

  Future<void> _loadSystemData() async {
    if (widget.systemId == null) return;

    try {
      final token = await StorageService.getToken();
      final systemData = await ApiService.getSystem(widget.systemId!, token: token);
      
      setState(() {
        _systemData = systemData;
      });

      // Load weather based on system location
      if (systemData['latitude'] != null && systemData['longitude'] != null) {
        _loadWeather(systemData['latitude'], systemData['longitude']);
      } else {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      print('Error loading system data: $e');
      setState(() {
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _loadWeather(double? lat, double? lon) async {
    if (lat == null || lon == null) {
      setState(() {
        _isLoadingWeather = false;
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
        _isLoadingWeather = false;
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
        _isLoadingWeather = false;
      });
    }
  }

  static const Color bgMain = Color(0xFFF5F5F0);
  static const Color headerGreen = Color(0xFF4A5D3F);
  static const Color greenText = Color(0xFF4A5D3F);
  static const Color darkText = Color(0xFF1A2A15);
  static const Color mutedText = Color(0xFF7A8D6F);
  static const Color cardGreen = Color(0xFFD4E4C8);
  static const Color paleGreen = Color(0xFFE8F0E0);

  String _extractValue(String? value) {
    if (value == null) return '0';
    final match = RegExp(r'[\d.]+').firstMatch(value);
    return match?.group(0) ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: headerGreen,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    InkWell(
                      onTap: widget.onBack,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.chevron_left,
                            color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'info sur le système',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ]),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('en ligne',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  )
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  children: [
                    // Weather Card - Make it clickable
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WeatherPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cardGreen,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: _isLoadingWeather
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Maintenant',
                                            style: TextStyle(
                                                color: greenText, fontSize: 13)),
                                        const SizedBox(height: 8),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                                '${_weatherData?['temperature'] ?? 26}°',
                                                style: const TextStyle(
                                                    fontSize: 48, color: darkText)),
                                            const SizedBox(width: 12),
                                            const SizedBox(
                                                width: 64,
                                                height: 64,
                                                child: WeatherIcon()),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                            'Max: ${_weatherData?['max'] ?? 28}°  Min: ${_weatherData?['min'] ?? 24}°',
                                            style: const TextStyle(
                                                color: greenText, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          _weatherData?['condition'] ?? 'Nuageux',
                                          style: const TextStyle(color: greenText)),
                                      const SizedBox(height: 6),
                                      Text(
                                          'Ressenti : ${_weatherData?['feels_like'] ?? 31}°',
                                          style: const TextStyle(
                                              color: Color(0xFF7A8D6F), fontSize: 12)),
                                    ],
                                  )
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.03,
                      children: [
                        _MetricCard(
                          background: Colors.white,
                          iconBackground: bgMain,
                          icon: const Icon(Icons.bolt,
                              size: 20, color: headerGreen),
                          title: 'Puissance actuelle',
                          value: _extractValue(widget.system.currentPower),
                          unit: 'kW',
                        ),
                        _MetricCard(
                          background: Colors.white,
                          iconBackground: bgMain,
                          icon: const Icon(Icons.battery_full,
                              size: 20, color: headerGreen),
                          title: 'Énergie du jour',
                          value: _extractValue(widget.system.dailyEnergy),
                          unit: 'kWh',
                        ),
                        _MetricCard(
                          background: paleGreen,
                          iconBackground: Colors.white,
                          icon: const _ClockIcon(),
                          title: 'Efficacité',
                          value: _extractValue(widget.system.efficiency),
                          unit: '%',
                        ),
                        _MetricCard(
                          background: paleGreen,
                          iconBackground: Colors.white,
                          icon: const Icon(Icons.water_drop,
                              size: 20, color: headerGreen),
                          title: 'Débit total',
                          value: _extractValue(widget.system.totalFlow),
                          unit: 'm³',
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: headerGreen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: widget.onBack,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home, color: Colors.white, size: 26),
                        SizedBox(height: 6),
                        Text('accueil',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: widget.onProfileClick,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, color: Color(0xCCFFFFFF), size: 26),
                        SizedBox(height: 6),
                        Text('Mon profile',
                            style: TextStyle(
                                color: Color(0xCCFFFFFF), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final Color background;
  final Color iconBackground;
  final Widget icon;
  final String title;
  final String value;
  final String unit;

  const _MetricCard({
    super.key,
    required this.background,
    required this.iconBackground,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
  });

  static const Color greenText = Color(0xFF4A5D3F);
  static const Color darkText = Color(0xFF1A2A15);
  static const Color mutedText = Color(0xFF7A8D6F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(999)),
                child: Center(child: icon),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: greenText, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      color: darkText,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              Text(unit, style: const TextStyle(color: mutedText)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClockIcon extends StatelessWidget {
  const _ClockIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _ClockPainter(),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint circle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF4A5D3F);
    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width / 2 - 1, circle);

    final Paint hand = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF4A5D3F);
    canvas.drawLine(center, Offset(center.dx, center.dy - 6), hand);
    canvas.drawLine(center, Offset(center.dx + 5, center.dy + 5), hand);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WeatherIcon extends StatelessWidget {
  const WeatherIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: 6,
          top: 4,
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFDB813),
            ),
          ),
        ),
        Positioned(
          right: 6,
          top: 0,
          child: SizedBox(
            width: 36,
            height: 36,
            child: CustomPaint(painter: _SunRaysPainter()),
          ),
        ),
        Positioned(
          left: 4,
          bottom: 2,
          child: CustomPaint(
            size: const Size(48, 28),
            painter: _CloudPainter(),
          ),
        ),
      ],
    );
  }
}

class _SunRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = const Color(0xFFFDB813)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width / 2, 2), Offset(size.width / 2, 8), p);
    canvas.drawLine(Offset(size.width - 2, size.height / 2),
        Offset(size.width - 8, size.height / 2), p);
    canvas.drawLine(Offset(size.width * 0.75, size.height * 0.25),
        Offset(size.width * 0.68, size.height * 0.33), p);
    canvas.drawLine(Offset(size.width * 0.75, size.height * 0.75),
        Offset(size.width * 0.68, size.height * 0.68), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = Colors.white;
    final Path path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.6);
    path.cubicTo(size.width * 0.05, size.height * 0.45, size.width * 0.18,
        size.height * 0.2, size.width * 0.4, size.height * 0.28);
    path.cubicTo(size.width * 0.45, size.height * 0.05, size.width * 0.78,
        size.height * 0.05, size.width * 0.8, size.height * 0.28);
    path.cubicTo(size.width * 0.95, size.height * 0.32, size.width * 0.95,
        size.height * 0.6, size.width * 0.7, size.height * 0.62);
    path.lineTo(size.width * 0.12, size.height * 0.62);
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

