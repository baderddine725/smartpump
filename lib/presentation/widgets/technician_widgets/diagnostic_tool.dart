import 'package:flutter/material.dart';

class DiagnosticTool extends StatelessWidget {
  const DiagnosticTool({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text('Diagnostic Technique', style: TextStyle(fontSize: 18)),
            // Add from EcranDiagnosticTechnicien snippet
          ],
        ),
      ),
    );
  }
}
