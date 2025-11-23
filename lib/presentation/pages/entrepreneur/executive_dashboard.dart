import 'package:flutter/material.dart';

class ExecutiveDashboardScreen extends StatelessWidget {
  const ExecutiveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Exécutif'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildKPISection(),
            const SizedBox(height: 20),
            _buildROISection(),
            const SizedBox(height: 20),
            _buildSitesPerformance(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildKPISection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Indicateurs Clés de Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildKPICard('ROI Moyen', '23.1%', Colors.green, Icons.trending_up),
                _buildKPICard('Disponibilité', '94.2%', Colors.blue, Icons.check_circle),
                _buildKPICard('TRI', '4.3 ans', Colors.orange, Icons.schedule),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildKPICard('Économies/mois', '7,400€', Colors.green, Icons.savings),
                _buildKPICard('Sites Actifs', '8/10', Colors.blue, Icons.business),
                _buildKPICard('MTBF', '156 jours', Colors.green, Icons.engineering),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildROISection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analyse ROI par Site',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DataTable(
              columns: const [
                DataColumn(label: Text('Site')),
                DataColumn(label: Text('Investissement')),
                DataColumn(label: Text('ROI Annuel')),
                DataColumn(label: Text('TRI')),
                DataColumn(label: Text('Statut')),
              ],
              rows: [
                _buildSiteRow('Site Nord', '32,000€', '23.1%', '4.3 ans', Colors.green),
                _buildSiteRow('Site Sud', '28,500€', '19.8%', '5.1 ans', Colors.green),
                _buildSiteRow('Site Est', '45,200€', '15.2%', '6.6 ans', Colors.orange),
                _buildSiteRow('Site Ouest', '38,700€', '26.4%', '3.8 ans', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildSiteRow(String site, String investment, String roi, String tri, Color statusColor) {
    return DataRow(cells: [
      DataCell(Text(site)),
      DataCell(Text(investment)),
      DataCell(Text(roi, style: TextStyle(color: _getROIColor(roi)))),
      DataCell(Text(tri)),
      DataCell(Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
      )),
    ]);
  }

  Color _getROIColor(String roi) {
    final value = double.parse(roi.replaceAll('%', ''));
    if (value >= 20) return Colors.green;
    if (value >= 15) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSitesPerformance() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance par Site',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPerformanceItem('Site Nord', 94.2, 7500, 0),
            _buildPerformanceItem('Site Sud', 89.5, 6800, 2),
            _buildPerformanceItem('Site Est', 92.1, 8200, 1),
            _buildPerformanceItem('Site Ouest', 96.8, 9100, 0),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(String siteName, double rate, double savings, int incidents) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: rate > 90 ? Colors.green : Colors.orange,
        child: Text('${rate.toStringAsFixed(0)}%'),
      ),
      title: Text(siteName),
      subtitle: Text('Économies: ${savings.toStringAsFixed(0)} €'),
      trailing: Chip(
        label: Text('$incidents incidents'),
        backgroundColor: incidents == 0 ? Colors.green : Colors.orange,
      ),
    );
  }
}
