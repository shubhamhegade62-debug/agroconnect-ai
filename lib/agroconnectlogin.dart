import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const AgroConnectApp());
}

class AgroConnectApp extends StatelessWidget {
  const AgroConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgroConnect',
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const FarmerLoginScreen(),
    );
  }
}

/// Color palette matching the AgroConnect design
class AppColors {
  static const darkGreen = Color(0xFF1B5E20);
  static const primaryGreen = Color(0xFF2E7D32);
  static const mediumGreen = Color(0xFF43A047);
  static const lightGreen = Color(0xFFE8F5E9);
  static const paleGreen = Color(0xFFF1F8F2);
  static const orange = Color(0xFFF9A825);
  static const turban = Color(0xFFE67E22);
  static const textDark = Color(0xFF1A1A1A);
  static const textGrey = Color(0xFF8A8A8A);
  static const fieldBorder = Color(0xFFE0E0E0);
}

class FarmerLoginScreen extends StatefulWidget {
  const FarmerLoginScreen({super.key});

  @override
  State<FarmerLoginScreen> createState() => _FarmerLoginScreenState();
}

class _FarmerLoginScreenState extends State<FarmerLoginScreen>
    with TickerProviderStateMixin {
  // Entrance animation controller
  late final AnimationController _entranceController;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _mobileFieldFade;
  late final Animation<Offset> _mobileFieldSlide;
  late final Animation<double> _passwordFieldFade;
  late final Animation<Offset> _passwordFieldSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;
  late final Animation<double> _googleFade;
  late final Animation<Offset> _googleSlide;
  late final Animation<double> _registerFade;
  late final Animation<Offset> _registerSlide;

  // Background leaves float/rotate loop
  late final AnimationController _leafController;

  // Login button press animation
  late final AnimationController _buttonPressController;
  late final Animation<double> _buttonScale;

  // Password visibility toggle animation
  late final AnimationController _eyeController;

  bool _obscurePassword = true;
  bool _isLoggingIn = false;

  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoFade = _buildFade(0.0, 0.35);
    _logoSlide = _buildSlide(0.0, 0.35);

    _headerFade = _buildFade(0.10, 0.45);
    _headerSlide = _buildSlide(0.10, 0.45);

    _mobileFieldFade = _buildFade(0.25, 0.60);
    _mobileFieldSlide = _buildSlide(0.25, 0.60);

    _passwordFieldFade = _buildFade(0.35, 0.70);
    _passwordFieldSlide = _buildSlide(0.35, 0.70);

    _buttonFade = _buildFade(0.45, 0.80);
    _buttonSlide = _buildSlide(0.45, 0.80);

    _googleFade = _buildFade(0.55, 0.90);
    _googleSlide = _buildSlide(0.55, 0.90);

    _registerFade = _buildFade(0.65, 1.0);
    _registerSlide = _buildSlide(0.65, 1.0);

    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _buttonPressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _buttonPressController, curve: Curves.easeOut),
    );

    _eyeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _entranceController.forward();
  }

  Animation<double> _buildFade(double start, double end) {
    return CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _buildSlide(double start, double end) {
    return Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _leafController.dispose();
    _buttonPressController.dispose();
    _eyeController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
      if (_obscurePassword) {
        _eyeController.reverse();
      } else {
        _eyeController.forward();
      }
    });
  }

  Future<void> _handleLoginTap() async {
    await _buttonPressController.forward();
    await _buttonPressController.reverse();
    setState(() => _isLoggingIn = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _isLoggingIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ---- Bottom decorative farmland (static illustration bar) ----
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FarmlandFooter(),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FadeTransition(
                          opacity: _mobileFieldFade,
                          child: SlideTransition(
                            position: _mobileFieldSlide,
                            child: _AnimatedTextField(
                              controller: _mobileController,
                              label: 'Mobile Number',
                              hint: 'Enter your mobile number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeTransition(
                          opacity: _passwordFieldFade,
                          child: SlideTransition(
                            position: _passwordFieldSlide,
                            child: _AnimatedTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              trailing: _AnimatedEyeIcon(
                                controller: _eyeController,
                                obscured: _obscurePassword,
                                onTap: _togglePassword,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeTransition(
                          opacity: _passwordFieldFade,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryGreen,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        FadeTransition(
                          opacity: _buttonFade,
                          child: SlideTransition(
                            position: _buttonSlide,
                            child: _buildLoginButton(),
                          ),
                        ),
                        const SizedBox(height: 22),
                        FadeTransition(
                          opacity: _googleFade,
                          child: Row(
                            children: [
                              const Expanded(
                                  child: Divider(color: AppColors.fieldBorder)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Expanded(
                                  child: Divider(color: AppColors.fieldBorder)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        FadeTransition(
                          opacity: _googleFade,
                          child: SlideTransition(
                            position: _googleSlide,
                            child: _buildGoogleButton(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeTransition(
                          opacity: _registerFade,
                          child: SlideTransition(
                            position: _registerSlide,
                            child: _buildRegisterCard(),
                          ),
                        ),
                        const SizedBox(height: 160),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return ClipPath(
      clipper: _CurveClipper(),
      child: Container(
        height: 420,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDCEFE3), Color(0xFFEFF7EE)],
          ),
        ),
        child: Stack(
          children: [
            // Floating decorative leaves (top-left corner)
            Positioned(
              top: -10,
              left: -10,
              child: AnimatedBuilder(
                animation: _leafController,
                builder: (context, child) {
                  final angle =
                      math.sin(_leafController.value * 2 * math.pi) * 0.06;
                  final dy =
                      math.sin(_leafController.value * 2 * math.pi) * 4;
                  return Transform.translate(
                    offset: Offset(0, dy),
                    child: Transform.rotate(angle: angle, child: child),
                  );
                },
                child: const _LeafCluster(size: 90),
              ),
            ),
            // Farmer illustration placeholder (right side)
            Positioned(
              right: 0,
              top: 130,
              bottom: 60,
              child: AnimatedBuilder(
                animation: _leafController,
                builder: (context, child) {
                  final dy =
                      math.sin(_leafController.value * 2 * math.pi + 1) * 5;
                  return Transform.translate(offset: Offset(0, dy), child: child);
                },
                child: const _FarmerIllustration(),
              ),
            ),
            // Logo + title + subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 50, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: SlideTransition(
                      position: _logoSlide,
                      child: _buildLogo(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Farmer Login',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Welcome back, let's continue\nyour farming journey!",
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textGrey,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _leafController,
          builder: (context, child) {
            final bob =
                math.sin(_leafController.value * 2 * math.pi) * 3;
            return Transform.translate(offset: Offset(0, bob), child: child);
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.mediumGreen, AppColors.primaryGreen],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(width: 10),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
            children: [
              TextSpan(
                  text: 'Agro', style: TextStyle(color: AppColors.darkGreen)),
              TextSpan(
                  text: 'Connect',
                  style: TextStyle(color: AppColors.mediumGreen)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoggingIn ? null : _handleLoginTap,
      child: AnimatedBuilder(
        animation: _buttonPressController,
        builder: (context, child) {
          final scale = 1 - _buttonPressController.value * 0.06;
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [AppColors.darkGreen, AppColors.primaryGreen],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkGreen.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: _isLoggingIn
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return _PressableScale(
      onTap: () {},
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.fieldBorder),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://www.google.com/favicon.ico',
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.g_mobiledata,
                color: Colors.redAccent,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Login with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterCard() {
    return _PressableScale(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.paleGreen,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightGreen),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco_outlined,
                  color: AppColors.primaryGreen, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New Farmer?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Create your account and start selling your produce directly to buyers.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textGrey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Register',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(height: 2),
                Icon(Icons.arrow_forward, color: AppColors.primaryGreen, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated text field with focus-based label color + border animation
class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? trailing;
  final TextInputType? keyboardType;

  const _AnimatedTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.trailing,
    this.keyboardType,
  });

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focused ? AppColors.primaryGreen : AppColors.fieldBorder,
          width: _focused ? 1.6 : 1,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _focused ? AppColors.primaryGreen : AppColors.lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: _focused ? Colors.white : AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _focused ? AppColors.primaryGreen : AppColors.textDark,
                  ),
                  child: Text(widget.label),
                ),
                TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  style: const TextStyle(fontSize: 15, color: AppColors.textDark),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          if (widget.trailing != null) widget.trailing!,
        ],
      ),
    );
  }
}

/// Animated eye icon that morphs between visible/hidden with a rotate+fade
class _AnimatedEyeIcon extends StatelessWidget {
  final AnimationController controller;
  final bool obscured;
  final VoidCallback onTap;

  const _AnimatedEyeIcon({
    required this.controller,
    required this.obscured,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: controller.value * math.pi,
            child: Icon(
              obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.textGrey,
              size: 22,
            ),
          );
        },
      ),
    );
  }
}

/// Generic press-scale wrapper for buttons/cards
class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScale({required this.child, required this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Simple leaf cluster drawn with icons (top-left corner decoration)
class _LeafCluster extends StatelessWidget {
  final double size;
  const _LeafCluster({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 10,
            child: Transform.rotate(
              angle: -0.4,
              child: Icon(Icons.eco, color: AppColors.mediumGreen.withOpacity(0.55), size: size * 0.55),
            ),
          ),
          Positioned(
            left: 20,
            top: -5,
            child: Transform.rotate(
              angle: 0.3,
              child: Icon(Icons.eco, color: AppColors.primaryGreen.withOpacity(0.4), size: size * 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder farmer illustration (silhouette using simple shapes,
/// since we can't embed the original photo). Swap with Image.asset(...)
/// pointing at your real illustration if you have the source file.
class _FarmerIllustration extends StatelessWidget {
  const _FarmerIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Turban
          Container(
            width: 70,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.turban,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          const SizedBox(height: 2),
          // Face
          Container(
            width: 46,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFC98A5B),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 4),
          // Body / shirt
          Container(
            width: 110,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFE1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
              border: Border.all(color: const Color(0xFFE0D8C0)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Icon(Icons.smartphone, color: AppColors.textGrey.withOpacity(0.6), size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

/// Static decorative footer strip resembling rolling farmland
class _FarmlandFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 130,
        width: double.infinity,
        child: CustomPaint(
          painter: _FarmlandPainter(),
        ),
      ),
    );
  }
}

class _FarmlandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = AppColors.lightGreen.withOpacity(0.5);
    final paint2 = Paint()..color = AppColors.lightGreen.withOpacity(0.8);

    final path1 = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.3,
          size.width * 0.5, size.height * 0.45)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.6, size.width, size.height * 0.4)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, paint1);

    final path2 = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.6,
          size.width * 0.6, size.height * 0.78)
      ..quadraticBezierTo(
          size.width * 0.85, size.height * 0.9, size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Curved clipper for the hero header's bottom edge
class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
        size.width * 0.5, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldDelegate) => false;
}