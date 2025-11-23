import 'package:flutter/material.dart';
import '../../../domain/entities/pump_status.dart';

class PumpStatusCard extends StatelessWidget {
  final PumpStatus pumpStatus;

  const PumpStatusCard({super.key, required this.pumpStatus});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.water, size: 50, color: Colors.blue),
            Text(pumpStatus.pumpName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // Add more from EcranAgriculteur snippet
          ],
        ),
      ),
    );
  }
}