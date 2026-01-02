import 'package:flutter/material.dart';
import 'passwordoublie.dart';
import 'inscription.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/phone_formatter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    const Color primaryGreen = Color(0xFF3E6B3E);
    const Color borderGreen = Color(0xFF9CBF93); 

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background image at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    'assets/images/image 20.png',
                    fit: BoxFit.fitWidth,
                    width: size.width,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            
            // Main scrollable content
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.vertical,
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),

                      Center(
                        child: Text(
                          'Connexion',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: primaryGreen,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Center(
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage('assets/images/avatar.png'),
                        ),
                      ),

                      const SizedBox(height: 26),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildRoundedInput(
                              controller: _phoneController,
                              hintText: 'numéro de téléphone',
                              prefix: Icons.phone,
                              borderColor: borderGreen,
                            ),

                            const SizedBox(height: 14),

                            _buildRoundedInput(
                              controller: _passwordController,
                              hintText: 'mot de passe',
                              prefix: Icons.lock,
                              borderColor: borderGreen,
                              isPassword: true,
                              obscure: _obscure,
                              onToggleObscure: () => setState(() => _obscure = !_obscure),
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 24),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'mot de passe oublié ?',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  elevation: 0,
                                  disabledBackgroundColor: Colors.grey,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Se connecter',
                                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Tu n\'as pas un compte ? ', style: TextStyle(color: Colors.black54)),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                                    );
                                  },
                                  child: Text(
                                    'créer un compte',
                                    style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    // Validate inputs
    if (phone.isEmpty) {
      _showError('Veuillez entrer votre numéro de téléphone');
      return;
    }

    if (password.isEmpty) {
      _showError('Veuillez entrer votre mot de passe');
      return;
    }

    // Format phone number to E.164 format
    final formattedPhone = PhoneFormatter.formatToE164(phone);
    
    // Validate the original input (before formatting) to give better error
    String digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      _showError('Le numéro de téléphone doit contenir entre 7 et 15 chiffres');
      return;
    }
    
    if (!PhoneFormatter.isValidPhoneNumber(formattedPhone)) {
      _showError('Numéro de téléphone invalide');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call backend API with formatted phone number
      final response = await ApiService.login(
        phone: formattedPhone,
        password: password,
      );

      if (response['success'] == true) {
        // Save token and user data
        final customToken = response['custom_token'] as String?;
        final userId = response['user_id'] as String?;
        final userData = response['user_data'] as Map<String, dynamic>?;

        if (customToken != null && userId != null) {
          await StorageService.saveToken(customToken);
          await StorageService.saveUserId(userId);
          
          // Save user data if available
          if (userData != null) {
            print('Saving user data: $userData');
            await StorageService.saveUserData(userData);
            print('User data saved successfully');
          } else {
            print('Warning: No user_data in login response');
          }

          // Navigate to home
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          _showError('Réponse invalide du serveur');
        }
      } else {
        _showError(response['message'] ?? 'Échec de la connexion');
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Erreur de connexion. Vérifiez votre connexion internet.');
      print('Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildRoundedInput({
    required TextEditingController controller,
    required String hintText,
    required IconData prefix,
    required Color borderColor,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: isPassword ? obscure : false,
              keyboardType: isPassword ? TextInputType.text : TextInputType.phone,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                hintText: hintText,
                hintStyle: TextStyle(color: Color(0xFF98AB94)),
                border: InputBorder.none,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                  child: Icon(prefix, color: Color(0xFF7F9B7F)),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 24),
              ),
            ),
          ),

          if (isPassword)
            InkWell(
              onTap: onToggleObscure,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(
                  obscure ? Icons.visibility_off : Icons.remove_red_eye,
                  color: Color(0xFF7F9B7F),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

