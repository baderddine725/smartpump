import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartpump/core/constants/app_constants.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = AppConstants.baseUrl});

  // GET
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur API: ${response.statusCode}');
    }
  }

  // POST
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur API: ${response.statusCode}');
    }
  }

  // PUT (optionnel)
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur API: ${response.statusCode}');
    }
  }

  // DELETE (optionnel)
  Future<void> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur API: ${response.statusCode}');
    }
  }
}
