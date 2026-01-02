import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation de fade-in
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Animation de scale
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    // Démarrer les animations
    _fadeController.forward();
    Timer(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });

    // Naviguer vers la page suivante 
    Timer(const Duration(seconds: 5), () { 
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7FEE7), // lime-50
              Color(0xFFECFCCB), // lime-100
              Color(0xFFF0FDF4), // green-50
            ],
          ),
        ),
        child: Stack(
          children: [
            // Cercles animés en arrière-plan
            _buildBackgroundCircles(),

            // Feuilles flottantes
            _buildFloatingLeaves(),

            // Contenu principal
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo avec animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildLogo(),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Titre
                    _buildTitle(),
                    
                    const SizedBox(height: 50),
                    
                    // Indicateur de chargement
                    _buildLoadingIndicator(),
                  ],
                ),
              ),
            ),

            // Vague décorative en bas
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomWave(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundCircles() {
    return Stack(
      children: [
        Positioned(
          top: 80,
          left: 40,
          child: _buildPulsingCircle(120, Colors.lime.shade300),
        ),
        Positioned(
          bottom: 120,
          right: 60,
          child: _buildPulsingCircle(150, Colors.green.shade300),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 2,
          left: MediaQuery.of(context).size.width / 4,
          child: _buildPulsingCircle(90, Colors.lime.shade300),
        ),
      ],
    );
  }

  Widget _buildPulsingCircle(double size, Color color) {
    return TweenAnimationBuilder(
      duration: const Duration(seconds: 2),
      tween: Tween<double>(begin: 0.8, end: 1.0),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildFloatingLeaves() {
    return Stack(
      children: [
        _buildAnimatedLeaf(
          top: 60,
          left: null,
          right: 80,
          size: 35,
          duration: 3,
          delay: 0,
          rotation: -20,
        ),
        _buildAnimatedLeaf(
          top: 100,
          left: 50,
          right: null,
          size: 28,
          duration: 4,
          delay: 0.5,
          rotation: 15,
        ),
        _buildAnimatedLeaf(
          top: 200,
          left: null,
          right: 40,
          size: 32,
          duration: 3.5,
          delay: 1,
          rotation: -15,
        ),
        _buildAnimatedLeaf(
          top: 250,
          left: 70,
          right: null,
          size: 30,
          duration: 4.5,
          delay: 0.3,
          rotation: 20,
        ),
        _buildAnimatedLeaf(
          top: null,
          bottom: 150,
          left: 40,
          right: null,
          size: 26,
          duration: 3.8,
          delay: 0.8,
          rotation: -10,
        ),
        _buildAnimatedLeaf(
          top: null,
          bottom: 200,
          left: null,
          right: 60,
          size: 33,
          duration: 4.2,
          delay: 0.2,
          rotation: 25,
        ),
      ],
    );
  }

  Widget _buildAnimatedLeaf({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double duration,
    required double delay,
    required double rotation,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: (duration * 1000).toInt()),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          final fallDistance = 30.0;
          final swingDistance = 15.0;
          
          return Transform.translate(
            offset: Offset(
              swingDistance * (value < 0.5 ? value * 2 : (1 - value) * 2),
              fallDistance * value,
            ),
            child: Transform.rotate(
              angle: (rotation + (value * 45)) * 3.14159 / 180,
              child: Opacity(
                opacity: 0.4 + (value * 0.3),
                child: Icon(
                  Icons.eco,
                  color: Colors.green.shade700,
                  size: size,
                ),
              ),
            ),
          );
        },
        onEnd: () {
          Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () {
            if (mounted) setState(() {});
          });
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 280,
      height: 280,
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/splash.png', 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF86EFAC),
                        Color(0xFF4ADE80),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.solar_power,
                    color: Colors.white,
                    size: 80,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Smart Solar',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4D7C0F),
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: Colors.black12,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const Text(
          'PUMP',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w900,
            color: Color(0xFF3F6212),
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: Colors.black12,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Gestion intelligente de la pompe solaire',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0, end: 10),
                builder: (context, double value, child) {
                  return Transform.translate(
                    offset: Offset(0, -value.abs()),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Color(0xFF15803D),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
                onEnd: () {
                  Future.delayed(Duration(milliseconds: index * 100), () {
                    if (mounted) setState(() {});
                  });
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBottomWave() {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, 100),
      painter: WavePainter(),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF3F6212) 
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.5,
    );
    
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.6,
      size.width,
      size.height * 0.5,
    );
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

