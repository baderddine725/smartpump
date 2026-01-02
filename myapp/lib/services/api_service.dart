import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  // Update this URL based on your setup:
  // - Android Emulator: http://10.0.2.2:8000
  // - iOS Simulator: http://localhost:8000
  // - Physical Device: http://YOUR_COMPUTER_IP:8000
  static const String baseUrl = 'http://localhost:8000/api';

  // Helper method for GET requests - can return Map or List
  static Future<dynamic> get(String endpoint, {String? token}) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Helper method for POST requests
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Helper method for PUT requests
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Helper method for DELETE requests
  static Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Handle HTTP response - can return Map or List
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      final decoded = jsonDecode(response.body);
      // Return as-is (could be Map or List)
      return decoded;
    } else {
      final errorBody = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      throw ApiException(
        statusCode: response.statusCode,
        message: errorBody['detail'] ?? errorBody['message'] ?? 'Request failed',
        data: errorBody,
      );
    }
  }

  // Authentication endpoints
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) async {
    return await post('/auth/signup', {
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    return await post('/auth/login', {
      'phone': phone,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> forgotPassword(String phone) async {
    return await post('/auth/forgot-password', {'phone': phone});
  }

  static Future<Map<String, dynamic>> verifyCode({
    required String phone,
    required String code,
  }) async {
    return await post('/auth/verify-code', {
      'phone': phone,
      'code': code,
    });
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    return await post('/auth/reset-password', {
      'phone': phone,
      'code': code,
      'new_password': newPassword,
    });
  }

  // System endpoints
  static Future<List<dynamic>> getSystems(String userId, {String? token}) async {
    final response = await get('/systems/?user_id=$userId', token: token);
    // Backend returns List directly, not wrapped in an object
    if (response is List) {
      return response;
    }
    // If it's a Map with a list inside, extract it
    if (response is Map && response['success'] != null) {
      return [];
    }
    // If response is already a list, return it
    if (response is List) {
      return response;
    }
    // Default: return empty list
    return [];
  }

  static Future<Map<String, dynamic>> getSystem(String systemId, {String? token}) async {
    final response = await get('/systems/$systemId', token: token);
    // Ensure it's a Map
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Invalid response format from getSystem');
  }

  static Future<Map<String, dynamic>> createSystem({
    required String userId,
    required String name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    String? token,
  }) async {
    return await post(
      '/systems/?user_id=$userId',
      {
        'name': name,
        if (description != null) 'description': description,
        if (location != null) 'location': location,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
      token: token,
    );
  }

  static Future<Map<String, dynamic>> updateSystem({
    required String systemId,
    required String userId,
    String? name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    String? token,
  }) async {
    return await put(
      '/systems/$systemId?user_id=$userId',
      {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (location != null) 'location': location,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
      token: token,
    );
  }

  static Future<Map<String, dynamic>> deleteSystem({
    required String systemId,
    required String userId,
    String? token,
  }) async {
    return await delete('/systems/$systemId?user_id=$userId', token: token);
  }

  // User endpoints
  static Future<Map<String, dynamic>> getUserProfile(String userId, {String? token}) async {
    final response = await get('/users/$userId/profile', token: token);
    // Ensure it's a Map
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Invalid response format from getUserProfile');
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? address,
    String? city,
    String? country,
    String? avatarUrl,
    String? token,
  }) async {
    return await put(
      '/users/$userId/profile',
      {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (country != null) 'country': country,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
      token: token,
    );
  }

  // Monitoring endpoints
  static Future<Map<String, dynamic>> getSystemMetrics(String systemId, {String? token}) async {
    final response = await get('/monitoring/$systemId/metrics', token: token);
    // Ensure it's a Map
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Invalid response format from getSystemMetrics');
  }

  static Future<Map<String, dynamic>> updateSystemMetrics({
    required String systemId,
    String? currentPower,
    String? dailyEnergy,
    String? efficiency,
    String? totalFlow,
    String? token,
  }) async {
    return await put(
      '/monitoring/$systemId/metrics',
      {
        if (currentPower != null) 'current_power': currentPower,
        if (dailyEnergy != null) 'daily_energy': dailyEnergy,
        if (efficiency != null) 'efficiency': efficiency,
        if (totalFlow != null) 'total_flow': totalFlow,
      },
      token: token,
    );
  }

  // Alert endpoints
  static Future<List<dynamic>> getSystemAlerts(String systemId, {String? token}) async {
    final response = await get('/alerts/system/$systemId', token: token);
    // Backend returns List directly
    if (response is List) {
      return response;
    }
    // If it's a Map with success, return empty list
    if (response is Map && response['success'] != null) {
      return [];
    }
    return [];
  }

  static Future<List<dynamic>> getUserAlerts(String userId, {String? token}) async {
    final response = await get('/alerts/user/$userId', token: token);
    // Backend returns List directly
    if (response is List) {
      return response;
    }
    // If it's a Map with success, return empty list
    if (response is Map && response['success'] != null) {
      return [];
    }
    return [];
  }

  // Weather endpoints
  static Future<Map<String, dynamic>> getWeather({
    required double latitude,
    required double longitude,
    String? token,
  }) async {
    final response = await post(
      '/weather',
      {
        'latitude': latitude,
        'longitude': longitude,
      },
      token: token,
    );
    // Ensure it's a Map
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Invalid response format from getWeather');
  }

  static Future<Map<String, dynamic>> getSystemStatus(String systemId, {String? token}) async {
    final response = await get('/monitoring/$systemId/status', token: token);
    // Ensure it's a Map
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Invalid response format from getSystemStatus');
  }

  static Future<List<dynamic>> getMetricsHistory(String systemId, {int limit = 100, String? token}) async {
    final response = await get('/monitoring/$systemId/history?limit=$limit', token: token);
    // Backend returns List directly
    if (response is List) {
      return response;
    }
    // If it's a Map with success, return empty list
    if (response is Map && response['success'] != null) {
      return [];
    }
    return [];
  }

  static Future<Map<String, dynamic>> resolveAlert(String alertId, {String? token}) async {
    return await post('/alerts/$alertId/resolve', {}, token: token);
  }

  // Photo upload endpoint
  static Future<Map<String, dynamic>> uploadProfilePhoto({
    required String userId,
    required String imagePath,
    String? token,
  }) async {
    try {
      final file = await http.MultipartFile.fromPath('file', imagePath);
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/avatar?user_id=$userId'),
      );
      
      request.files.add(file);
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Log response for debugging
      print('Upload response status: ${response.statusCode}');
      print('Upload response body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

// Custom exception class
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? data;

  ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

