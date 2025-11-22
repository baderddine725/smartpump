import 'package:flutter/material.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ----------- TOP BAR -----------
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
            title: const Text("Météo actuelle",
                style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),

      // ----------- BODY -----------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // BIG WEATHER CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFA2C392),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT PART
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Maintenant",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                      SizedBox(height: 8),
                      Text(
                        "26°",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Max : 28°   Min : 24°"),
                    ],
                  ),

                  // RIGHT PART
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Nuageux",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      const Text("Ressenti 31°"),
                      const SizedBox(height: 4),
                      Image.asset(
                        "assets/icons/cloud_sun.png",
                        width: 70,
                      )
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // FILTER BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _weatherTab("Aujourd’hui", true),
                _weatherTab("Demain", false),
                _weatherTab("10 jours", false),
              ],
            ),

            const SizedBox(height: 20),

            // SMALL WEATHER INFO CARDS
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                          Icons.air, "Vitesse du vent", "12 km/h"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                          Icons.water_drop, "Précipitation", "86%"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                          Icons.sunny, "Lev/Cou du soleil", "6:03 / 17:34"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          _infoCard(Icons.cloud, "Humidité", "60%"),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      // ----------- BOTTOM NAV BAR -----------
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF4A6B3E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Mon profile"),
        ],
      ),
    );
  }

  // ---- SMALL COMPONENTS ----
  Widget _weatherTab(String text, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Color(0xFFA2C392) : Color(0xFFEAEFE7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5E4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
