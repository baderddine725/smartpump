// system_detail_page.dart
import 'package:flutter/material.dart';

/// Simple model class equivalent to your `System` type.
class System {
  final String currentPower; // e.g. "2.4"
  final String dailyEnergy; // e.g. "18.2"
  final String efficiency; // e.g. "86"
  final String totalFlow; // e.g. "120"

  System({
    required this.currentPower,
    required this.dailyEnergy,
    required this.efficiency,
    required this.totalFlow,
  });
}

/// Page widget that mimics the layout from your React component.
class SystemDetailPage extends StatelessWidget {
  final System system;
  final VoidCallback onBack;
  final VoidCallback onProfileClick;

  const SystemDetailPage({
    super.key,
    required this.system,
    required this.onBack,
    required this.onProfileClick,
  });

  // Helper color palette from your CSS
  static const Color bgMain = Color(0xFFF5F5F0);
  static const Color headerGreen = Color(0xFF4A5D3F);
  static const Color greenText = Color(0xFF4A5D3F);
  static const Color darkText = Color(0xFF1A2A15);
  static const Color mutedText = Color(0xFF7A8D6F);
  static const Color cardGreen = Color(0xFFD4E4C8);
  static const Color paleGreen = Color(0xFFE8F0E0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                    // Back button
                    InkWell(
                      onTap: onBack,
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

            // Content area
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  children: [
                    // Weather Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardGreen,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side (temps, icon)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Maintenant',
                                    style: TextStyle(
                                        color: greenText, fontSize: 13)),
                                SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('26°',
                                        style: TextStyle(
                                            fontSize: 48, color: darkText)),
                                    SizedBox(width: 12),
                                    // Small custom weather visual
                                    SizedBox(
                                        width: 64,
                                        height: 64,
                                        child: WeatherIcon()),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Text('Max: 28°  Min: 24°',
                                    style: TextStyle(
                                        color: greenText, fontSize: 12)),
                              ],
                            ),
                          ),

                          // Right side (description)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Nuageux',
                                  style: TextStyle(color: greenText)),
                              SizedBox(height: 6),
                              Text('Ressenti : 31°',
                                  style: TextStyle(
                                      color: Color(0xFF7A8D6F), fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Metrics grid 2x2
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.03,
                      children: [
                        // Current Power
                        _MetricCard(
                          background: Colors.white,
                          iconBackground: bgMain,
                          icon: const Icon(Icons.bolt,
                              size: 20, color: headerGreen),
                          title: 'Puissance actuelle',
                          value: system.currentPower,
                          unit: 'kW',
                        ),

                        // Daily Energy
                        _MetricCard(
                          background: Colors.white,
                          iconBackground: bgMain,
                          icon: const Icon(Icons.battery_full,
                              size: 20, color: headerGreen),
                          title: 'Énergie du jour',
                          value: system.dailyEnergy,
                          unit: 'kWh',
                        ),

                        // Efficiency
                        _MetricCard(
                          background: paleGreen,
                          iconBackground: Colors.white,
                          icon: const _ClockIcon(),
                          title: 'Efficacité',
                          value: system.efficiency,
                          unit: '%',
                        ),

                        // Total Flow
                        _MetricCard(
                          background: paleGreen,
                          iconBackground: Colors.white,
                          icon: const Icon(Icons.water_drop,
                              size: 20, color: headerGreen),
                          title: 'Débit total',
                          value: system.totalFlow,
                          unit: 'm³',
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),

            // Bottom navigation bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: headerGreen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home button
                  InkWell(
                    onTap: onBack,
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

                  // Profile button
                  InkWell(
                    onTap: onProfileClick,
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

/// Small reusable metric card used in the grid.
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
          // icon row
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

/// Small custom icon that draws a circular clock-like icon (used in your TSX SVG).
class _ClockIcon extends StatelessWidget {
  const _ClockIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // We use Icon widget with a CircleAvatar to mimic the SVG circle + hands
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
    // vertical hand
    canvas.drawLine(center, Offset(center.dx, center.dy - 6), hand);
    // diagonal hand
    canvas.drawLine(center, Offset(center.dx + 5, center.dy + 5), hand);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Small custom weather graphic: sun + cloud (approximation of your inline SVG)
class WeatherIcon extends StatelessWidget {
  const WeatherIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // Composed widget using Stack to simulate sun + cloud
    return Stack(
      alignment: Alignment.center,
      children: [
        // sun (circle)
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

        // small sun rays (simple)
        Positioned(
          right: 6,
          top: 0,
          child: SizedBox(
            width: 36,
            height: 36,
            child: CustomPaint(painter: _SunRaysPainter()),
          ),
        ),

        // cloud
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
    // four small rays
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
    // approximate cloud shape
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
