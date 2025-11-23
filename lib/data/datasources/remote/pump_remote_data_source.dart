import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data/models/pump/pump_status.dart';

class PumpRemoteDataSourceImpl {
  final http.Client client;

  PumpRemoteDataSourceImpl({required this.client});

  Future<PumpStatusModel> getPumpStatus(String pumpId) async {
    final response = await client
        .get(Uri.parse('https://api.example.com/pumps/$pumpId/status'));
    if (response.statusCode == 200) {
      return PumpStatusModel.fromJson(json.decode(response.body));
    } else {
      throw ServerFailure();
    }
  }
}
