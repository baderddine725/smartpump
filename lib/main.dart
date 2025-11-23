import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/pages/farmer/farmer_home_screen.dart';
import 'presentation/blocs/pump/pump_status_bloc/pump_status_bloc.dart';
import 'data/repositories/mock_pump_repository.dart';
import 'domain/repositories/pump_repository_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<PumpRepositoryInterface>(
      create: (context) => MockPumpRepository(),
      child: BlocProvider(
        create: (context) => PumpStatusBloc(
          pumpRepository: context.read<PumpRepositoryInterface>(),
        )..add(AllPumpsStatusRequested()),
        child: MaterialApp(
          title: 'Pompes Solaires',
          theme: ThemeData(
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const FarmerHomeScreen(farmerId: 'farmer_001'),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}