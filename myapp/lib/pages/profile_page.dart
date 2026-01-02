import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/phone_formatter.dart';
import 'settings_page.dart';

const customGreen = Color(0xFF4A6B3E);

class ProfilePage extends StatefulWidget {
  final VoidCallback? onManageSystems;
  final VoidCallback? onServices;
  final VoidCallback? onHome;

  const ProfilePage({
    super.key,
    this.onManageSystems,
    this.onServices,
    this.onHome,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  String _formatPhoneNumber(String phone) {
    if (phone == 'No phone' || phone.isEmpty) return phone;
    // If already in +216 format, return as is
    if (phone.startsWith('+216')) return phone;
    // Format to +216 if it's a Tunisian number
    return PhoneFormatter.formatToE164(phone, defaultCountryCode: '+216');
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userId = await StorageService.getUserId();
      final token = await StorageService.getToken();

      if (userId == null || token == null) {
        setState(() {
          _error = 'Not logged in';
          _isLoading = false;
        });
        return;
      }

      // Try to fetch from API first
      try {
        final userData = await ApiService.getUserProfile(userId, token: token);
        print('Loaded user data - avatar_url: ${userData['profile']?['avatar_url']}');
        setState(() {
          _userData = userData;
          _isLoading = false;
          _error = null;
        });
        return;
      } catch (apiError) {
        // If API fails, try to use cached data from login
        print('API fetch failed: $apiError, trying cached data...');
        final cachedData = await StorageService.getUserData();
        if (cachedData != null && cachedData.isNotEmpty) {
          setState(() {
            _userData = cachedData;
            _isLoading = false;
            _error = null;
          });
          return;
        }
        // If both fail, show error
        throw apiError;
      }
    } catch (e) {
      print('Profile load error: $e');
      setState(() {
        _error = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profile", style: TextStyle(color: customGreen)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: customGreen, width: 2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: customGreen,
                                backgroundImage: _userData?['profile']?['avatar_url'] != null &&
                                        _userData!['profile']['avatar_url'].toString().isNotEmpty &&
                                        _userData!['profile']['avatar_url'] != 'null'
                                    ? NetworkImage(_userData!['profile']['avatar_url'])
                                    : null,
                                onBackgroundImageError: (exception, stackTrace) {
                                  print('Error loading avatar image: $exception');
                                },
                                child: _userData?['profile']?['avatar_url'] == null ||
                                        _userData!['profile']['avatar_url'].toString().isEmpty ||
                                        _userData!['profile']['avatar_url'] == 'null'
                                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userData?['name'] ?? 'No name',
                                    style: const TextStyle(
                                      color: customGreen,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _formatPhoneNumber(_userData?['phone'] ?? 'No phone'),
                                    style: const TextStyle(color: customGreen),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit, color: customGreen),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfilePage(
                                        userData: _userData,
                                        onProfileUpdated: _loadUserProfile,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
            const SizedBox(height: 30),
                        const SizedBox(height: 30),
                        MenuButton(
                          title: "Services",
                          icon: Icons.design_services,
                          onPressed: () {
                            if (widget.onServices != null) {
                              widget.onServices!();
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        MenuButton(
                          title: "Gérer les systèmes",
                          icon: Icons.build,
                          onPressed: () {
                            if (widget.onManageSystems != null) {
                              widget.onManageSystems!();
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        MenuButton(
                          title: "Paramètres",
                          icon: Icons.settings,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        MenuButton(
                          title: "Déconnexion",
                          icon: Icons.logout,
                          onPressed: () async {
                            await StorageService.clearAll();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: Container(
        color: customGreen,
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BottomNavButton(
              icon: Icons.home,
              label: "Accueil",
              onTap: () {
                if (widget.onHome != null) {
                  widget.onHome!();
                } else {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
            ),
            BottomNavButton(
              icon: Icons.person,
              label: "Mon Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      userData: _userData,
                      onProfileUpdated: _loadUserProfile,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onPressed;

  const MenuButton({
    super.key,
    required this.title,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: customGreen,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class BottomNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BottomNavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback? onProfileUpdated;

  const EditProfilePage({
    super.key,
    this.userData,
    this.onProfileUpdated,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.userData?['phone'] ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Modifier Profile", style: TextStyle(color: customGreen)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: customGreen),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: customGreen,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : (widget.userData?['profile']?['avatar_url'] != null
                      ? NetworkImage(widget.userData!['profile']['avatar_url'])
                      : null) as ImageProvider?,
              child: _selectedImage == null &&
                      (widget.userData?['profile']?['avatar_url'] == null)
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image, color: customGreen),
              label: const Text("Changer Photo", style: TextStyle(color: customGreen)),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Nom",
              iconLeft: Icons.person,
              controller: _nameController,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: "Numéro téléphone",
              iconLeft: Icons.phone,
              controller: _phoneController,
              enabled: false, // Phone number shouldn't be changed
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: "Nouveau mot de passe (laisser vide pour ne pas changer)",
              iconLeft: Icons.lock,
              controller: _passwordController,
              isPassword: !_showPassword,
              iconRight: _showPassword ? Icons.visibility : Icons.visibility_off,
              onIconRightPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: "Confirmer mot de passe",
              iconLeft: Icons.lock,
              controller: _confirmPasswordController,
              isPassword: !_showConfirmPassword,
              iconRight: _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
              onIconRightPressed: () {
                setState(() {
                  _showConfirmPassword = !_showConfirmPassword;
                });
              },
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveProfile,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                _isLoading ? "Enregistrement..." : "Enregistrer",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: customGreen,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                disabledBackgroundColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty) {
      _showError('Le nom ne peut pas être vide');
      return;
    }

    if (password.isNotEmpty) {
      if (password.length < 6) {
        _showError('Le mot de passe doit contenir au moins 6 caractères');
        return;
      }
      if (password != confirmPassword) {
        _showError('Les mots de passe ne correspondent pas');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await StorageService.getUserId();
      final token = await StorageService.getToken();

      if (userId == null || token == null) {
        _showError('Non connecté');
        return;
      }

      String? avatarUrl;

      // Upload image if one was selected
      if (_selectedImage != null) {
        try {
          print('Starting photo upload...');
          final uploadResult = await ApiService.uploadProfilePhoto(
            userId: userId,
            imagePath: _selectedImage!.path,
            token: token,
          );
          
          print('Upload result: $uploadResult');
          
          if (uploadResult['success'] == true) {
            avatarUrl = uploadResult['avatar_url'] as String?;
            print('Upload successful! Avatar URL: $avatarUrl');
          } else {
            // If upload fails, continue without avatar URL (don't block profile update)
            print('Warning: Image upload failed, continuing without avatar');
          }
        } catch (e) {
          // If upload fails, check if it's a 404 (route not found)
          String errorMessage = 'Erreur lors de l\'upload de la photo';
          if (e.toString().contains('404') || e.toString().contains('Not Found')) {
            errorMessage = 'Erreur: Le serveur backend doit être redémarré pour activer l\'upload de photos. Le profil sera mis à jour sans la photo.';
          } else {
            errorMessage = 'Erreur lors de l\'upload de la photo: $e';
          }
          
          print('Error uploading image: $e');
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          // Continue without avatar URL (don't block profile update)
        }
      }
      
      print('Updating profile with avatarUrl: $avatarUrl');

      // Update profile with name and avatar URL
      print('Calling updateUserProfile with avatarUrl: $avatarUrl');
      await ApiService.updateUserProfile(
        userId: userId,
        name: name,
        avatarUrl: avatarUrl,
        token: token,
      );
      print('Profile updated successfully');

      // If password is provided, update it (would need a separate endpoint)
      // For now, we'll just update the name

      // Refresh profile data after update - wait for it to complete
      if (widget.onProfileUpdated != null) {
        print('Refreshing profile data...');
        widget.onProfileUpdated!();
        // Give it a moment to load
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: customGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Erreur lors de la mise à jour: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // Upload image to backend (placeholder - would need backend endpoint)
        // For now, just save locally
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo sélectionnée (upload à implémenter)'),
            backgroundColor: customGreen,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData? iconLeft;
  final IconData? iconRight;
  final bool isPassword;
  final VoidCallback? onIconRightPressed;
  final TextEditingController? controller;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.label,
    this.iconLeft,
    this.iconRight,
    this.isPassword = false,
    this.onIconRightPressed,
    this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: customGreen),
        prefixIcon: iconLeft != null ? Icon(iconLeft, color: customGreen) : null,
        suffixIcon: iconRight != null
            ? IconButton(
                icon: Icon(iconRight, color: customGreen),
                onPressed: onIconRightPressed,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: customGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: customGreen, width: 2),
        ),
      ),
    );
  }
}

