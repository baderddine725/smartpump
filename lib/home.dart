// home_page.dart
import 'package:flutter/material.dart';
import 'system_detail_page.dart'; // assume this exists in same folder

/// Model definitions (compatible with SystemDetailPage)
class System {
  final String id;
  final String name;
  final String currentPower;
  final String dailyEnergy;
  final String efficiency;
  final String totalFlow;

  System({
    required this.id,
    required this.name,
    required this.currentPower,
    required this.dailyEnergy,
    required this.efficiency,
    required this.totalFlow,
  });

  // convenience factory for mocks
  factory System.mock(String id, String name) => System(
        id: id,
        name: name,
        currentPower: (10 + int.parse(id) * 2).toString(),
        dailyEnergy: (100 + int.parse(id) * 10).toString(),
        efficiency: (80 + int.parse(id)).toString(),
        totalFlow: (200 + int.parse(id) * 5).toString(),
      );
}

class AlertItem {
  final String id;
  final String title;
  final String? subtitle;

  AlertItem({required this.id, required this.title, this.subtitle});
}

/// HomePage widget
class HomePage extends StatelessWidget {
  final List<System> systems;
  final List<AlertItem> alerts;
  final Function(System) onSystemClick;
  final VoidCallback onProfileClick;
  final VoidCallback onAddSystem; // Ajoutez ce paramètre

  const HomePage({
    super.key,
    required this.systems,
    required this.alerts,
    required this.onSystemClick,
    required this.onProfileClick,
    required this.onAddSystem, // Ajoutez ici
  });

  static const Color bgMain = Color(0xFFF5F5F0);
  static const Color headerGreen = Color(0xFF4A5D3F);

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
                  const Text('Salut foulen',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D7350),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onPressed: () {
                      // Placeholder for add action
                      onAddSystem(); // Utilisez onAddSystem ici
                    },
                    child: const Row(
                      children: [
                        Text('Ajouter'),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.fromBorderSide(
                                  BorderSide(color: Colors.white, width: 2)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                            ),
                            child: Center(
                                child: Text('+',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Efficiency Card
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5D7350), Color(0xFF4A5D3F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // left text block
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Efficacité',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                                SizedBox(height: 6),
                                Text('95%',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 6),
                                Text('Gérez votre énergie',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                                Text('pour produire',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                                Text('efficacement',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),

                          // right image
                          Container(
                            width: 110,
                            height: 80,
                            margin: const EdgeInsets.only(left: 8),
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12)),
                            child: Image.network(
                              'https://images.unsplash.com/flagged/photo-1566838616631-f2618f74a6a2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: Colors.grey[200]),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Systems list
                    Column(
                      children: systems.map((system) {
                        return Padding(
                          key: ValueKey(system.id),
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () {
                              // call the provided callback
                              onSystemClick(system);
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4E4C8),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(system.name,
                                      style: const TextStyle(
                                          color: Color(0xFF4A5D3F),
                                          fontSize: 15)),
                                  const Icon(Icons.chevron_right,
                                      color: Color(0xFF4A5D3F)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    // Alerts Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Derniers alertes',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ],
                          ).withBackground(const Color(0xFF5D7350)),
                          const SizedBox(height: 10),
                          Column(
                            children: alerts.map((alert) {
                              return Padding(
                                key: ValueKey(alert.id),
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Alert tapped: ${alert.title}')),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F0E0),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(alert.title,
                                                  style: const TextStyle(
                                                      color:
                                                          Color(0xFF4A5D3F))),
                                              if (alert.subtitle != null) ...[
                                                const SizedBox(height: 4),
                                                Text(alert.subtitle!,
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xFF7A8D6F),
                                                        fontSize: 12)),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right,
                                            color: Color(0xFF7A8D6F)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom navigation
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: headerGreen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home - passive
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home, color: Colors.white, size: 24),
                      SizedBox(height: 6),
                      Text('accueil',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),

                  // Profile - active
                  InkWell(
                    onTap: onProfileClick,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, color: Color(0xCCFFFFFF), size: 24),
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

/// Small extension to wrap a widget row with a colored pill background (used for alert header).
extension _WidgetWithBg on Widget {
  Widget withBackground(Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: this,
    );
  }
}
