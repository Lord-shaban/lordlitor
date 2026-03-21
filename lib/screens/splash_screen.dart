import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    HapticFeedback.mediumImpact();
    _navigateToHome();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) {
      HapticFeedback.lightImpact();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF58CC02),
              Color(0xFF4CB801),
              Color(0xFF3EA000),
              Color(0xFF348A02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background pattern - subtle diagonal lines
            ...List.generate(6, (i) => Positioned(
              top: -100 + i * (size.height / 4),
              left: -200,
              child: Transform.rotate(
                angle: -0.4,
                child: Container(
                  width: size.width * 2,
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            )),

            // Large decorative circles
            Positioned(
              top: -size.width * 0.3,
              right: -size.width * 0.2,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -size.width * 0.4,
              left: -size.width * 0.3,
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),

            // Floating sparkles
            ..._buildSparkles(size),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Mascot character with float animation
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatController.value * 12 - 6),
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow behind mascot
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, _) {
                              return Container(
                                width: 160 + _pulseController.value * 20,
                                height: 160 + _pulseController.value * 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.15 + _pulseController.value * 0.1),
                                      blurRadius: 40 + _pulseController.value * 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          // White circle background
                          Container(
                            width: 155,
                            height: 155,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                          ),
                          // Mascot image - using transparent PNG
                          ClipOval(
                            child: Image.asset(
                              'lib/image/logo_without_bg.png',
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 32),

                  // App name
                  Text(
                    AppConstants.appName,
                    style: GoogleFonts.cairo(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

                  const SizedBox(height: 10),

                  // Tagline chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      AppConstants.appTagline,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 550.ms)
                      .slideY(begin: 0.3, end: 0),

                  const Spacer(flex: 2),

                  // Loading indicator - Duolingo-style progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: Column(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: const LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                                .animate()
                                .fadeIn(delay: 800.ms, duration: 300.ms),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'جاري التحميل...',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 900.ms, duration: 400.ms),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSparkles(Size size) {
    final sparkles = <Widget>[];
    final positions = [
      [0.15, 0.12, 8.0],
      [0.82, 0.15, 6.0],
      [0.08, 0.45, 5.0],
      [0.92, 0.50, 7.0],
      [0.25, 0.78, 5.0],
      [0.75, 0.82, 6.0],
      [0.55, 0.10, 4.0],
      [0.40, 0.88, 5.0],
    ];

    for (int i = 0; i < positions.length; i++) {
      sparkles.add(
        Positioned(
          left: size.width * positions[i][0],
          top: size.height * positions[i][1],
          child: Container(
            width: positions[i][2],
            height: positions[i][2],
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          )
              .animate(
                onPlay: (c) => c.repeat(reverse: true),
              )
              .scaleXY(
                begin: 0.3,
                end: 1.0,
                duration: (1200 + i * 200).ms,
                delay: (i * 150).ms,
              )
              .fadeIn(duration: 500.ms, delay: (300 + i * 100).ms),
        ),
      );
    }
    return sparkles;
  }
}
