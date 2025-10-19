import 'package:flutter/material.dart';
import '../services/oauth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await OAuthService.login();
      
      if (result != null && mounted) {
        // Login successful, navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (mounted) {
        // User cancelled or login failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login was cancelled or failed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A23), // Deep space blue
              Color(0xFF1A0033), // Dark purple
              Color(0xFF2D1B69), // Electric purple
              Color(0xFF0F0F23), // Dark navy
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Synthwave grid background
            CustomPaint(
              painter: SynthwaveGridPainter(),
              size: Size.infinite,
            ),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Neon 42 Logo
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: const Color(0xFFFF00FF), // Neon magenta
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF00FF).withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: const Color(0xFF00FFFF).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFF00FF), // Neon magenta
                            Color(0xFF00FFFF), // Neon cyan
                            Color(0xFFFF0080), // Hot pink
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          '42',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    
                    // Synthwave App Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFF00FF), // Neon magenta
                          Color(0xFF00FFFF), // Neon cyan
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'SWIFTY COMPANION',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 6,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Retro subtitle with scan lines effect
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF00FFFF).withOpacity(0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '> NEURAL LINK TO 42 NETWORK <',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF00FFFF),
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                    
                    // Neon Login Button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: const Color(0xFFFF00FF),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: const BorderSide(
                              color: Color(0xFFFF00FF),
                              width: 2,
                            ),
                          ),
                          elevation: 0,
                        ).copyWith(
                          overlayColor: WidgetStateProperty.all(
                            const Color(0xFFFF00FF).withOpacity(0.1),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF00FF).withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      const Color(0xFF00FFFF),
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) => const LinearGradient(
                                        colors: [
                                          Color(0xFFFF00FF),
                                          Color(0xFF00FFFF),
                                        ],
                                      ).createShader(bounds),
                                      child: const Icon(
                                        Icons.flash_on,
                                        size: 26,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ShaderMask(
                                      shaderCallback: (bounds) => const LinearGradient(
                                        colors: [
                                          Color(0xFFFF00FF),
                                          Color(0xFF00FFFF),
                                        ],
                                      ).createShader(bounds),
                                      child: const Text(
                                        'JACK IN',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 3,
                                          fontFamily: 'monospace',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    // Retro info text
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF00FFFF).withOpacity(0.2),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFF000011).withOpacity(0.3),
                      ),
                      child: const Text(
                        'ESTABLISHING SECURE CONNECTION TO CYBERNET...\nAUTHORIZATION PROTOCOL: OAUTH-2077',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF00FFFF),
                          letterSpacing: 1,
                          height: 1.4,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Scan line overlay
            Positioned.fill(
              child: CustomPaint(
                painter: ScanLinePainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for synthwave grid background
class SynthwaveGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF00FF).withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw perspective grid
    const int gridLines = 20;
    const double perspectiveOffset = 0.3;
    
    // Vertical lines with perspective
    for (int i = 0; i <= gridLines; i++) {
      final double x = (i / gridLines) * size.width;
      final double topOffset = (x - size.width / 2) * perspectiveOffset;
      
      canvas.drawLine(
        Offset(x + topOffset, size.height * 0.6),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Horizontal lines
    for (int i = 0; i <= gridLines ~/ 2; i++) {
      final double y = size.height * 0.6 + (i / (gridLines / 2)) * (size.height * 0.4);
      final double perspectiveWidth = (1 - (i / (gridLines / 2)) * perspectiveOffset) * size.width;
      final double startX = (size.width - perspectiveWidth) / 2;
      
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + perspectiveWidth, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for scan line effect
class ScanLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.05)
      ..strokeWidth = 1;

    // Draw horizontal scan lines
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}