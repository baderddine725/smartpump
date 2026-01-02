import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/phone_formatter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  static const Color primaryGreen = Color(0xFF3E6B3E);
  static const Color borderGreen = Color(0xFF9CBF93);
  static const Color lightGrey = Color(0xFF98AB94);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

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
                    'assets/images/image 19.png',
                    fit: BoxFit.fitWidth,
                    width: size.width,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            
            // Main scrollable content
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      Text(
                        'Inscription',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: primaryGreen,
                        ),
                      ),

                      const SizedBox(height: 40),

                      _buildInputFieldWithIcon(
                        controller: _nameController,
                        hintText: 'Nom',
                        icon: Icons.person,
                      ),

                      const SizedBox(height: 16),

                      _buildInputFieldWithIcon(
                        controller: _phoneController,
                        hintText: 'numéro de téléphone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 16),

                      _buildInputFieldWithIcon(
                        controller: _passwordController,
                        hintText: 'mot de passe',
                        icon: Icons.lock,
                        isPassword: true,
                        obscure: _obscurePassword,
                        onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),

                      const SizedBox(height: 16),

                      _buildInputFieldWithIcon(
                        controller: _confirmPasswordController,
                        hintText: 'Confirmer mot de passe',
                        icon: Icons.lock,
                        isPassword: true,
                        obscure: _obscureConfirmPassword,
                        onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
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
                                  'Créer un compte',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Tu es déjà un compte ? ',
                            style: TextStyle(color: Colors.black54),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Connectez vous',
                              style: TextStyle(
                                color: primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
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

  Widget _buildInputFieldWithIcon({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderGreen, width: 2),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 12.0),
            child: Icon(
              icon,
              color: Color(0xFF7F9B7F),
              size: 20,
            ),
          ),

          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: isPassword ? obscure : false,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 8,
                ),
                hintText: hintText,
                hintStyle: TextStyle(color: lightGrey, fontSize: 16),
                border: InputBorder.none,
              ),
            ),
          ),

          if (isPassword)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFF7F9B7F),
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _createAccount() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Veuillez entrer votre nom');
      return;
    }

    if (phone.isEmpty) {
      _showSnackBar('Veuillez entrer votre numéro de téléphone');
      return;
    }

    if (password.isEmpty) {
      _showSnackBar('Veuillez entrer un mot de passe');
      return;
    }

    if (confirmPassword.isEmpty) {
      _showSnackBar('Veuillez confirmer votre mot de passe');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Les mots de passe ne correspondent pas');
      return;
    }

    // Format phone number to E.164 format
    final formattedPhone = PhoneFormatter.formatToE164(phone);
    
    // Validate the original input (before formatting) to give better error
    String digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      _showSnackBar('Le numéro de téléphone doit contenir entre 7 et 15 chiffres');
      return;
    }
    
    if (!PhoneFormatter.isValidPhoneNumber(formattedPhone)) {
      _showSnackBar('Numéro de téléphone invalide');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.signup(
        name: name,
        phone: formattedPhone,
        password: password,
      );

      if (response['success'] == true) {
        final customToken = response['custom_token'] as String?;
        final userId = response['user_id'] as String?;

        if (customToken != null && userId != null) {
          await StorageService.saveToken(customToken);
          await StorageService.saveUserId(userId);
          
          // Save initial user data
          await StorageService.saveUserData({
            'name': name,
            'phone': formattedPhone,
            'uid': userId,
          });

          _showSnackBar('Compte créé avec succès!');
          
          // Navigate to home
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          _showSnackBar('Réponse invalide du serveur');
        }
      } else {
        _showSnackBar(response['message'] ?? 'Échec de la création du compte');
      }
    } on ApiException catch (e) {
      _showSnackBar(e.message);
    } catch (e) {
      _showSnackBar('Erreur de connexion. Vérifiez votre connexion internet.');
      print('Signup error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

