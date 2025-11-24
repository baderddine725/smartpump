import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smartpump/core/errors/failure.dart';
import 'package:smartpump/data/models/pump/pump_status.dart';

abstract class PumpRemoteDataSource {
  Future<PumpStatusModel> getPumpStatus(String pumpId);
}

class PumpRemoteDataSourceImpl implements PumpRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  PumpRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<PumpStatusModel> getPumpStatus(String pumpId) async {
    final response =
        await client.get(Uri.parse('$baseUrl/pumps/$pumpId/status'));

    if (response.statusCode == 200) {
      return PumpStatusModel.fromJson(json.decode(response.body));
    }

    throw const ServerFailure('Impossible de récupérer le statut de la pompe');
  }
}
