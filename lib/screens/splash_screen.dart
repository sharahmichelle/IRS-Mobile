// lib/screens/splash_screen_minimal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upm_drrm_irs_mobile/providers/auth_provider.dart';

class SplashScreenMinimal extends StatefulWidget {
  const SplashScreenMinimal({super.key});

  @override
  State<SplashScreenMinimal> createState() => _SplashScreenMinimalState();
}

class _SplashScreenMinimalState extends State<SplashScreenMinimal>
    with TickerProviderStateMixin {
  // Red gradient colors
  static const Color _primaryRed = Color(0xFFE63946);
  static const Color _darkRed = Color(0xFFD00000);
  
  late AnimationController _rippleController;
  late AnimationController _fadeController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Ripple animation controller
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _fadeController.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 5000));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryRed, _darkRed],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Concentric circles ripple effect - centered with logo
            AnimatedBuilder(
              animation: _rippleController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildRipple(0.0),
                    _buildRipple(0.25),
                    _buildRipple(0.5),
                    _buildRipple(0.75),
                  ],
                );
              },
            ),
            
            // Logo centered in the middle of screen (aligned with ripples)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 70, // Adjust to center logo with ripples
              child: FadeTransition(
                opacity: _logoFadeAnimation,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/favicon.png',
                      width: 100,
                      height: 100,
                      color: _primaryRed,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.shield_rounded,
                          size: 80,
                          color: _primaryRed,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            // Text content at the bottom part of screen
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.25,
              child: FadeTransition(
                opacity: _textFadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Incident Reporting System',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Disaster Risk Reduction and Management',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'in Health Program',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRipple(double delay) {
    final double size = 400;
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        double progress = (_rippleController.value + delay) % 1.0;
        double opacity = 1.0 - progress;
        double scale = 0.3 + (progress * 1.2);
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(opacity * 0.35),
                width: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}