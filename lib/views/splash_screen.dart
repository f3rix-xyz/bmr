import 'package:dtx/views/home_screen.dart';
import 'package:dtx/views/phone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dtx/utils/token_storage.dart'; // Add this import

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;
  bool _animationComplete = false;
  bool _statusCheckComplete = false;
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _checkToken();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const ElasticOutCurve(1.5),
      ),
    );

    _rotateAnim = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const ElasticOutCurve(1.5),
      ),
    );

    _controller.forward();
    
    // Mark animation as complete after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _animationComplete = true;
        });
        _navigateIfReady();
      }
    });
  }
  
  Future<void> _checkToken() async {
    try {
      // Check if token exists
      final token = await TokenStorage.getToken();
      
      if (mounted) {
        setState(() {
          _hasToken = token != null && token.isNotEmpty;
          _statusCheckComplete = true;
        });
        _navigateIfReady();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasToken = false;
          _statusCheckComplete = true;
        });
        _navigateIfReady();
      }
    }
  }
  
  void _navigateIfReady() {
    // Only navigate if both animation has played sufficiently and status check is done
    if (_animationComplete && _statusCheckComplete) {
      Widget destination;
      
      if (_hasToken) {
        destination = const HomeScreen();
      } else {
        destination = const PhoneInputScreen();
      }
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double responsiveFontSize =
        screenSize.height * 0.1; // ~7% of screen height
    final double subtitleFontSize =
        screenSize.height * 0.02; // ~2% of screen height
    final double bottomPadding = screenSize.height * 0.05; // 5% from bottom

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnim.value,
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: Transform.rotate(
                        angle: _rotateAnim.value,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Peeple Admin',  // Changed to indicate admin app
                            style: GoogleFonts.pacifico(
                              fontSize: responsiveFontSize,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.75),
                                  blurRadius: screenSize.width *
                                      0.03, // 3% of screen width
                                  offset: Offset(
                                    screenSize.width * 0.005, // 0.5% of width
                                    screenSize.height * 0.005, // 0.5% of height
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: bottomPadding,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _fadeAnim,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnim.value,
                    child: Text(
                      'Admin Dashboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Show loading indicator if status check is taking time
            if (_animationComplete && !_statusCheckComplete)
              Positioned(
                bottom: bottomPadding + 40,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
