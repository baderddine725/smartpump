import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/pump_status_bloc/pump_status_bloc.dart';

class TechnicianDashboardScreen extends StatelessWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic des pannes')),
      body: BlocBuilder<PumpStatusBloc, PumpStatusState>(
        builder: (context, state) {
          // Similar to pump_error_screen.dart snippet
          if (state is PumpStatusLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PumpStatusLoadSuccess) {
            // Display technical details
            return Center(child: Text('Statut technique: ${state.pumpStatus.status}'));
          } else if (state is PumpStatusLoadFailure) {
            return Center(child: Text('Erreur: ${state.error}'));
          } else {
            return const Center(child: Text('État inconnu'));
          }
        },
      ),
    );
  }
}