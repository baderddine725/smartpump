import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/pump/pump_status_bloc/pump_status_bloc.dart';
import '../../../domain/repositories/pump_repository_interface.dart';

class FarmerHomeScreen extends StatelessWidget {
  final String farmerId;

  const FarmerHomeScreen({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PumpStatusBloc(
        pumpRepository: context.read<PumpRepositoryInterface>(),
      )..add(AllPumpsStatusRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Pompes Solaires'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<PumpStatusBloc, PumpStatusState>(
            builder: (context, state) {
              if (state is PumpStatusLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AllPumpsStatusLoadSuccess) {
                return ListView.builder(
                  itemCount: state.pumpsStatus.length,
                  itemBuilder: (context, index) {
                    final pump = state.pumpsStatus[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(pump.pumpName,
                                style: const TextStyle(fontSize: 20)),
                            Text('Statut: ${pump.status}'),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<PumpStatusBloc>()
                                  .add(PumpStartRequested(pumpId: pump.pumpId)),
                              child: const Text('Démarrer'),
                            ),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<PumpStatusBloc>()
                                  .add(PumpStopRequested(pumpId: pump.pumpId)),
                              child: const Text('Arrêter'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (state is PumpStatusLoadFailure) {
                return Center(child: Text('Erreur: ${state.error}'));
              } else {
                return const Center(child: Text('État inconnu'));
              }
            },
          ),
        ),
      ),
    );
  }
}
