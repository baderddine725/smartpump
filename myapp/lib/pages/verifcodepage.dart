import 'package:flutter/material.dart';
import 'resetpassword.dart';
import '../services/api_service.dart';

class VerificationCodePage extends StatefulWidget {
  final String phoneNumber;
  
  const VerificationCodePage({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final List<TextEditingController> _codeControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  bool _isLoading = false;
  
  static const Color primaryGreen = Color(0xFF3E6B3E);
  static const Color borderGreen = Color(0xFF9CBF93);
  static const Color lightGrey = Color(0xFF98AB94);

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus && _codeControllers[i].text.isEmpty) {
          if (i > 0) {
            _focusNodes[i-1].requestFocus();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_isAllFieldsFilled()) {
      _verifyCode();
    }
  }

  bool _isAllFieldsFilled() {
    return _codeControllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getVerificationCode() {
    return _codeControllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                height: size.height,
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Text(
                      'Entrer le code',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Code envoyé au ${widget.phoneNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        color: lightGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return SizedBox(
                          width: 60,
                          height: 60,
                          child: TextFormField(
                            controller: _codeControllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderGreen, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryGreen, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderGreen, width: 2),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: primaryGreen,
                            ),
                            onChanged: (value) => _onCodeChanged(value, index),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Vous n'avez pas reçu le code ? ",
                          style: TextStyle(color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: () {
                            _resendCode();
                          },
                          child: Text(
                            'Renvoyer le code',
                            style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Color(0xFFE0E0E0),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (_isAllFieldsFilled() && !_isLoading) ? _verifyCode : null,
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
                                'Vérifier le code',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                      ),

                    const Spacer(),
                    SizedBox(height: size.height * 0.15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyCode() async {
    final code = _getVerificationCode();
    
    if (code.length != 4) {
      _showSnackBar('Veuillez entrer le code complet');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.verifyCode(
        phone: widget.phoneNumber,
        code: code,
      );

      if (response['success'] == true && response['verified'] == true) {
        _showSnackBar('Code vérifié avec succès!');
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordPage(
                phoneNumber: widget.phoneNumber,
                verificationCode: code,
              ),
            ),
          );
        }
      } else {
        _showSnackBar('Code invalide. Veuillez réessayer.');
      }
    } on ApiException catch (e) {
      _showSnackBar(e.message);
    } catch (e) {
      _showSnackBar('Erreur de connexion. Vérifiez votre connexion internet.');
      print('Verify code error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    try {
      final response = await ApiService.forgotPassword(widget.phoneNumber);
      if (response['success'] == true) {
        _showSnackBar('Code renvoyé avec succès!');
      } else {
        _showSnackBar('Échec de l\'envoi du code');
      }
    } catch (e) {
      _showSnackBar('Erreur lors de l\'envoi du code');
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

