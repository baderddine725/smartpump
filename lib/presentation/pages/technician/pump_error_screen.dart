import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/pump/pump_error_bloc/pump_error_bloc.dart';
import '../../../data/repositories/pump_error_repository.dart';

class PumpErrorScreen extends StatelessWidget {
  final String pumpId;

  const PumpErrorScreen({super.key, required this.pumpId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic des pannes')),
      body: BlocProvider(
        create: (context) => PumpErrorBloc(
          pumpErrorRepository: PumpErrorRepositoryImpl(),
        )..add(PumpErrorRequested(pumpId: pumpId)),
        child: BlocBuilder<PumpErrorBloc, PumpErrorState>(
          builder: (context, state) {
            if (state is PumpErrorInitial || state is PumpErrorLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PumpErrorLoadSuccess) {
              final pumpErrors = state.pumpErrors;
              if (pumpErrors.isEmpty) {
                return const Center(
                  child: Text('Aucune erreur détectée'),
                );
              }
              return ListView.builder(
                itemCount: pumpErrors.length,
                itemBuilder: (context, index) {
                  final error = pumpErrors[index];
                  return ListTile(
                    leading: Icon(
                      Icons.error,
                      color: _getSeverityColor(error.severity),
                    ),
                    title: Text('${error.errorCode}: ${error.description}'),
                    subtitle: Text(
                      '${error.timestamp.day}/${error.timestamp.month}/${error.timestamp.year} ${error.timestamp.hour}:${error.timestamp.minute}',
                    ),
                    trailing: Text(error.severity),
                    onTap: () => _showErrorDetails(context, error),
                  );
                },
              );
            } else if (state is PumpErrorLoadFailure) {
              return Center(child: Text('Erreur: ${state.error}'));
            } else {
              return const Center(child: Text('État inconnu'));
            }
          },
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  void _showErrorDetails(BuildContext context, error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails: ${error.errorCode}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description: ${error.description}'),
              const SizedBox(height: 16),
              const Text(
                'Causes possibles:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...error.possibleCauses.map((cause) => Text('• $cause')),
              const SizedBox(height: 16),
              const Text(
                'Solutions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...error.solutions.map((solution) => Text('• $solution')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

