import 'package:flutter/material.dart';
import 'weather.dart';

class InfoSystemePage extends StatelessWidget {
  const InfoSystemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      // ---------------- TOP BAR ----------------
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
            leading: const Icon(Icons.arrow_back, color: Colors.white),
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

      // ---------------- BODY ----------------
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 14),

            // ---------------- WEATHER CARD (CLICABLE) ----------------
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
                      children: const [
                        Text("Maintenant", style: TextStyle(fontSize: 18)),
                        SizedBox(height: 6),
                        Text(
                          "26°",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Max: 28°   Min: 24°"),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Nuageux", style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 4),
                        const Text("Ressenti : 31°"),
                        const SizedBox(height: 4),
                        Image.asset(
                          'assets/icons/cloud_sun.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- CARDS: Puissance, Énergie, Efficacité, Débit ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  // FIRST ROW
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: _smallCard(
                          icon: Icons.electric_bolt,
                          title: "Puissance actuelle",
                          value: "5.2",
                          unit: "kW",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        fit: FlexFit.tight,
                        child: _smallCard(
                          icon: Icons.battery_charging_full,
                          title: "Énergie du jour",
                          value: "387",
                          unit: "kWh",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // SECOND ROW
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: _smallCard(
                          icon: Icons.speed,
                          title: "Efficacité",
                          value: "94.2",
                          unit: "%",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        fit: FlexFit.tight,
                        child: _smallCard(
                          icon: Icons.water_drop,
                          title: "Débit total",
                          value: "1200",
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

      // ---------------- BOTTOM BAR ----------------
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

  // ---------------- SMALL CARD ----------------
  Widget _smallCard({
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
        color: Color.fromARGB(77, 207, 243, 190), // 30% opacité sur #CFF3BE
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
