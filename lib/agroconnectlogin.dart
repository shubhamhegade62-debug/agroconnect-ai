import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'shared_widgets.dart';
import 'farmer_register_screen.dart';

class agrologin extends StatefulWidget {
  const agrologin({super.key});

  @override
  State<agrologin> createState() => _agrologinState();
}

class _agrologinState extends State<agrologin> with TickerProviderStateMixin {
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
    setState(() => _isLoggingIn = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _isLoggingIn = false);
  }

  void _goToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const FarmerRegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ---- Bottom decorative farmland (static illustration bar) ----
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FarmlandFooter(),
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
                            child: AnimatedTextField(
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
                            child: AnimatedTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              trailing: AnimatedEyeIcon(
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
                            child: PrimaryGradientButton(
                              label: 'Login',
                              icon: Icons.login,
                              isLoading: _isLoggingIn,
                              onTap: _handleLoginTap,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        FadeTransition(
                          opacity: _googleFade,
                          child: Row(
                            children: [
                              const Expanded(
                                  child:
                                      Divider(color: AppColors.fieldBorder)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Expanded(
                                  child:
                                      Divider(color: AppColors.fieldBorder)),
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
      clipper: CurveClipper(),
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
                  final dy = math.sin(_leafController.value * 2 * math.pi) * 4;
                  return Transform.translate(
                    offset: Offset(0, dy),
                    child: Transform.rotate(angle: angle, child: child),
                  );
                },
                child: const LeafCluster(size: 90),
              ),
            ),
            // Farmer illustration (right side)
            Positioned(
              right: 0,
              top: 130,
              bottom: 60,
              child: AnimatedBuilder(
                animation: _leafController,
                builder: (context, child) {
                  final dy =
                      math.sin(_leafController.value * 2 * math.pi + 1) * 5;
                  return Transform.translate(
                      offset: Offset(0, dy), child: child);
                },
                child: const FarmerIllustration(),
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
                      child: AnimatedLogo(leafController: _leafController),
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

  Widget _buildGoogleButton() {
    return PressableScale(
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
    return PressableScale(
      onTap: _goToRegister,
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
                Icon(Icons.arrow_forward,
                    color: AppColors.primaryGreen, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}