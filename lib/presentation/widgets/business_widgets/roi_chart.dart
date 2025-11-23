import 'package:flutter/material.dart';

class RoiAnalysisChart extends StatelessWidget {
  const RoiAnalysisChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Analyse ROI'),
            // Add progress bar from EcranTableauBordBusiness snippet
            LinearProgressIndicator(value: 0.6),
          ],
        ),
      ),
    );
  }
}
