import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationCode;
  
  const ResetPasswordPage({
    Key? key,
    required this.phoneNumber,
    required this.verificationCode,
  }) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  static const Color primaryGreen = Color(0xFF3E6B3E);
  static const Color borderGreen = Color(0xFF9CBF93);
  static const Color lightGrey = Color(0xFF98AB94);

  @override
  void dispose() {
    _newPasswordController.dispose();
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
                    'assets/images/image 21.png',
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
                      const SizedBox(height: 40),
                      Text(
                        'Nouveau mot de passe',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: primaryGreen,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Créez un nouveau mot de passe sécurisé',
                        style: TextStyle(
                          fontSize: 16,
                          color: lightGrey,
                        ),
                      ),

                      const SizedBox(height: 40),

                      _buildPasswordField(
                        controller: _newPasswordController,
                        hintText: 'Nouveau mot de passe',
                        obscure: _obscureNewPassword,
                        onToggleObscure: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                      ),

                      const SizedBox(height: 20),

                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirmer le nouveau mot de passe',
                        obscure: _obscureConfirmPassword,
                        onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),

                      const SizedBox(height: 35),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
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
                                  'Enregistrer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscure,
    required VoidCallback onToggleObscure,
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
              Icons.lock,
              color: Color(0xFF7F9B7F),
              size: 20,
            ),
          ),

          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
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

  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty) {
      _showSnackBar('Veuillez entrer le nouveau mot de passe');
      return;
    }

    if (confirmPassword.isEmpty) {
      _showSnackBar('Veuillez confirmer le nouveau mot de passe');
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('Les mots de passe ne correspondent pas');
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.resetPassword(
        phone: widget.phoneNumber,
        code: widget.verificationCode,
        newPassword: newPassword,
      );

      if (response['success'] == true) {
        _showSnackBar('Mot de passe réinitialisé avec succès!');
        
        // Wait a bit before navigating
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          _navigateToLogin();
        }
      } else {
        _showSnackBar(response['message'] ?? 'Échec de la réinitialisation');
      }
    } on ApiException catch (e) {
      _showSnackBar(e.message);
    } catch (e) {
      _showSnackBar('Erreur de connexion. Vérifiez votre connexion internet.');
      print('Reset password error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/login',
      (route) => false,
    );
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

