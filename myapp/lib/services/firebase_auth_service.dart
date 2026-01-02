import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service to verify password with Firebase using REST API
class FirebaseAuthService {
  static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY'; // Get from Firebase Console
  
  /// Verify password using Firebase REST API
  /// Returns ID token if password is correct
  static Future<String?> verifyPassword(String email, String password) async {
    try {
      final url = 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$firebaseApiKey';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['idToken'] as String?;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      throw Exception('Password verification failed: $e');
    }
  }
}

