import 'package:flutter/material.dart';
import 'verifcodepage.dart';
import '../services/api_service.dart';
import '../utils/phone_formatter.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  static const Color primaryGreen = Color(0xFF3E6B3E);
  static const Color borderGreen = Color(0xFF9CBF93);
  static const Color lightGrey = Color(0xFF98AB94);

  @override
  void dispose() {
    _phoneController.dispose();
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
              child: Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: Text(
                          'Mot de passe oublié',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: primaryGreen,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Center(
                        child: Text(
                          'Réinitialisez votre mot de passe',
                          style: TextStyle(
                            fontSize: 16,
                            color: lightGrey,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      Center(
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage('assets/images/avatar.png'),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: borderGreen, width: 2),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 16,
                                  ),
                                  hintText: 'numéro de téléphone',
                                  hintStyle: TextStyle(color: lightGrey, fontSize: 16),
                                  border: InputBorder.none,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                                    child: Icon(Icons.phone, color: Color(0xFF7F9B7F), size: 20),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendVerificationCode,
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
                                  'Envoyer le code',
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

  Future<void> _sendVerificationCode() async {
    final phoneNumber = _phoneController.text.trim();
    
    if (phoneNumber.isEmpty) {
      _showSnackBar('Veuillez entrer votre numéro de téléphone');
      return;
    }

    // Format phone number to E.164 format
    final formattedPhone = PhoneFormatter.formatToE164(phoneNumber);
    
    // Validate the original input (before formatting) to give better error
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
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
      final response = await ApiService.forgotPassword(formattedPhone);

      if (response['success'] == true) {
        _showSnackBar('Code de vérification envoyé');
        
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationCodePage(phoneNumber: formattedPhone),
            ),
          );
        }
      } else {
        _showSnackBar(response['message'] ?? 'Échec de l\'envoi du code');
      }
    } on ApiException catch (e) {
      _showSnackBar(e.message);
    } catch (e) {
      _showSnackBar('Erreur de connexion. Vérifiez votre connexion internet.');
      print('Forgot password error: $e');
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

