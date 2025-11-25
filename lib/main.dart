import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ProfilePage(),
    );
  }
}

const customGreen = Color(0xFF4A6B3E);

/* ------------------------- PAGE MON PROFILE ------------------------- */
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
      body: SingleChildScrollView(
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
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: customGreen,
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Foulen Fouleni",
                          style: TextStyle(
                              color: customGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text("22553322", style: TextStyle(color: customGreen)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: customGreen),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditProfilePage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            MenuButton(title: "Services", icon: Icons.design_services),
            const SizedBox(height: 15),
            MenuButton(title: "Gérer les systèmes", icon: Icons.build),
            const SizedBox(height: 15),
            MenuButton(title: "Paramètres", icon: Icons.settings),
            const SizedBox(height: 30),
            MenuButton(title: "Déconnexion", icon: Icons.logout),
          ],
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
                // action pour Accueil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Accueil cliqué !")),
                );
              },
            ),
            BottomNavButton(
              icon: Icons.person,
              label: "Mon Profile",
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const EditProfilePage()));
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
  const MenuButton({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
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

  const BottomNavButton(
      {super.key, required this.icon, required this.label, required this.onTap});

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

/* ------------------------- PAGE EDIT PROFILE ------------------------ */
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _showPassword = false;
  bool _showConfirmPassword = false;

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
            const CircleAvatar(
              radius: 50,
              backgroundColor: customGreen,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.image, color: customGreen),
              label: const Text("Changer Photo", style: TextStyle(color: customGreen)),
            ),
            const SizedBox(height: 20),
            // Nom et téléphone à gauche
            CustomTextField(
              label: "Nom",
              iconLeft: Icons.person,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: "Numéro téléphone",
              iconLeft: Icons.phone,
            ),
            const SizedBox(height: 15),
            // Mot de passe
            CustomTextField(
              label: "Mot de passe",
              iconLeft: Icons.lock,
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
              onPressed: () {},
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text("Enregistrer",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: customGreen,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Champ texte avec icône gauche et droite pour mot de passe
class CustomTextField extends StatelessWidget {
  final String label;
  final IconData? iconLeft;
  final IconData? iconRight;
  final bool isPassword;
  final VoidCallback? onIconRightPressed;

  const CustomTextField({
    super.key,
    required this.label,
    this.iconLeft,
    this.iconRight,
    this.isPassword = false,
    this.onIconRightPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword,
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
