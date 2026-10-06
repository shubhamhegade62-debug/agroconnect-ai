// ============================================================================
// AgroConnect - Animated Role Selection / Onboarding Screen
// ----------------------------------------------------------------------------
// A full, self-contained Flutter implementation with:
//   • Animated gradient sky background + drifting clouds + parallax hills
//   • Leaf decorations that fade & rotate in
//   • Logo entrance animation (scale + fade + gentle float loop)
//   • Staggered title / subtitle slide-fade-in
//   • Farmer & Buyer role cards with:
//        - staggered slide-in entrance
//        - press-down scale animation (tactile feedback)
//        - selection highlight animation (border glow + scale)
//        - animated arrow button (bounce on tap)
//   • "Continue as Guest" fade-in link
//   • Fully responsive, works on any screen size
//
// HOW TO USE:
//   1. Create a new Flutter project:  flutter create agroconnect
//   2. Replace lib/main.dart with this file's contents.
//   3. flutter pub get && flutter run
//
// No external packages required — pure Flutter SDK animations
// (AnimationController, TweenSequence, Curves, Hero, etc.)
// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'agroconnectlogin.dart';

void main() {
  runApp(const AgroApp());
}

class AgroApp extends StatelessWidget {
  const AgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
      ),
      home: const RoleSelectionScreen(),
    );
  }
}

// ============================================================================
// MAIN SCREEN
// ============================================================================

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  // ---- Master entrance controller (drives staggered intervals below) ----
  late final AnimationController _entranceController;

  // Logo
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  // Leaves
  late final Animation<double> _leafFadeLeft;
  late final Animation<double> _leafFadeRight;

  // Title block
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _subtitleFade;

  // Cards
  late final Animation<Offset> _farmerCardSlide;
  late final Animation<double> _farmerCardFade;
  late final Animation<Offset> _buyerCardSlide;
  late final Animation<double> _buyerCardFade;

  // Guest link
  late final Animation<double> _guestFade;

  // ---- Continuous floating loop for the logo (idle breathing effect) ----
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  // ---- Drifting clouds loop ----
  late final AnimationController _cloudController;

  // Track which role is selected (for highlight animation)
  String? _selectedRole;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    _leafFadeLeft = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.05, 0.3, curve: Curves.easeOut),
      ),
    );
    _leafFadeRight = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.35, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.55, curve: Curves.easeIn),
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.62, curve: Curves.easeOutCubic),
      ),
    );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.62, curve: Curves.easeIn),
      ),
    );

    _farmerCardSlide = Tween<Offset>(
      begin: const Offset(-0.4, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.82, curve: Curves.easeOutCubic),
      ),
    );
    _farmerCardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.82, curve: Curves.easeIn),
      ),
    );

    _buyerCardSlide = Tween<Offset>(
      begin: const Offset(0.4, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.68, 0.95, curve: Curves.easeOutCubic),
      ),
    );
    _buyerCardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.68, 0.95, curve: Curves.easeIn),
      ),
    );

    _guestFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  void _selectRole(String role) {
    HapticFeedback.selectionClick();
    setState(() => _selectedRole = role);
    Future.delayed(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const agrologin(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ---------------- Animated background ----------------
          Positioned.fill(child: _AnimatedSkyBackground(cloudController: _cloudController)),

          // ---------------- Decorative leaves ----------------
          Positioned(
            top: 40,
            left: 0,
            child: FadeTransition(
              opacity: _leafFadeLeft,
              child: Transform.rotate(
                angle: -0.2,
                child: const _LeafDecoration(size: 90),
              ),
            ),
          ),
          Positioned(
            top: 90,
            right: 0,
            child: FadeTransition(
              opacity: _leafFadeRight,
              child: Transform.rotate(
                angle: 0.5,
                child: const _LeafDecoration(size: 80, mirrored: true),
              ),
            ),
          ),

          // ---------------- Main content ----------------
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // ---- Logo ----
                    AnimatedBuilder(
                      animation: Listenable.merge([_entranceController, _floatController]),
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoFade.value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: const _AgroLogo(),
                    ),

                    const SizedBox(height: 8),

                    // ---- Title ----
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleFade,
                        child: const Text(
                          'Welcome to AgroConnect',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF14361A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ---- Subtitle ----
                    SlideTransition(
                      position: _subtitleSlide,
                      child: FadeTransition(
                        opacity: _subtitleFade,
                        child: Text(
                          'Choose your role to get started',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ---- Farmer card ----
                    SlideTransition(
                      position: _farmerCardSlide,
                      child: FadeTransition(
                        opacity: _farmerCardFade,
                        child: _RoleCard(
                          role: 'Farmer',
                          title: 'Farmer',
                          description:
                              'Sell your produce directly to buyers, get best prices and market insights.',
                          accentColor: const Color(0xFF2E7D32),
                          backgroundColor: const Color(0xFFEDF7EE),
                          icon: Icons.agriculture_rounded,
                          isSelected: _selectedRole == 'Farmer',
                          onTap: () => _selectRole('Farmer'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---- Buyer card ----
                    SlideTransition(
                      position: _buyerCardSlide,
                      child: FadeTransition(
                        opacity: _buyerCardFade,
                        child: _RoleCard(
                          role: 'Buyer',
                          title: 'Buyer',
                          description:
                              'Find fresh produce, connect with farmers and place orders directly.',
                          accentColor: const Color(0xFF1565C0),
                          backgroundColor: const Color(0xFFEAF2FB),
                          icon: Icons.storefront_rounded,
                          isSelected: _selectedRole == 'Buyer',
                          onTap: () => _selectRole('Buyer'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // ---- Continue as Guest ----
                    FadeTransition(
                      opacity: _guestFade,
                      child: _GuestLink(onTap: () => _selectRole('Guest')),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ANIMATED BACKGROUND: sky gradient + drifting clouds + layered hills
// ============================================================================

class _AnimatedSkyBackground extends StatelessWidget {
  final AnimationController cloudController;
  const _AnimatedSkyBackground({required this.cloudController});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4FAF4), Color(0xFFFFFFFF)],
        ),
      ),
      child: Stack(
        children: [
          // Drifting clouds (loop across the screen)
          AnimatedBuilder(
            animation: cloudController,
            builder: (context, _) {
              final t = cloudController.value;
              return Stack(
                children: [
                  _cloud(size.width * (0.9 - t) - 40, 40, 70),
                  _cloud(size.width * (1.5 - t) - 60, 90, 55),
                  _cloud(size.width * (0.3 - t + 1) % (size.width + 80) - 40, 130, 45),
                ],
              );
            },
          ),

          // Layered rolling hills near top-third of the screen
          Positioned(
            top: size.height * 0.28,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(size.width, 140),
              painter: _HillsPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cloud(double left, double top, double w) {
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: 0.5,
        child: Icon(Icons.cloud_rounded, size: w, color: const Color(0xFFDCEBDD)),
      ),
    );
  }
}

class _HillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backHill = Paint()..color = const Color(0xFFCFE8CF).withValues(alpha: 0.6);
    final midHill = Paint()..color = const Color(0xFFBBDFBB).withValues(alpha: 0.7);
    final frontHill = Paint()..color = const Color(0xFFA9D6A9).withValues(alpha: 0.8);

    Path buildHill(double heightFactor, double phase) {
      final path = Path();
      path.moveTo(0, size.height);
      path.lineTo(0, size.height * heightFactor);
      for (double x = 0; x <= size.width; x += 1) {
        final y = size.height * heightFactor +
            10 * math.sin((x / size.width * 2 * math.pi) + phase);
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();
      return path;
    }

    canvas.drawPath(buildHill(0.5, 0), backHill);
    canvas.drawPath(buildHill(0.65, 1.5), midHill);
    canvas.drawPath(buildHill(0.8, 3.0), frontHill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// LOGO WIDGET
// ============================================================================

class _AgroLogo extends StatelessWidget {
  const _AgroLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Leaf + sun icon mark
        SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5A623),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Icon(Icons.eco_rounded, size: 70, color: Colors.green.shade800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            children: [
              TextSpan(text: 'Agro', style: TextStyle(color: Colors.green.shade700)),
              const TextSpan(text: 'Connect', style: TextStyle(color: Color(0xFF14361A))),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 24, height: 1.4, color: Colors.green.shade400),
            const SizedBox(width: 8),
            Text(
              'Direct Farmer to Buyer',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 24, height: 1.4, color: Colors.green.shade400),
          ],
        ),
      ],
    );
  }
}

class _LeafDecoration extends StatelessWidget {
  final double size;
  final bool mirrored;
  const _LeafDecoration({required this.size, this.mirrored = false});

  @override
  Widget build(BuildContext context) {
    final icon = Icon(Icons.eco_rounded, size: size, color: Colors.green.shade200);
    return mirrored ? Transform.flip(flipX: true, child: icon) : icon;
  }
}

// ============================================================================
// ROLE CARD (Farmer / Buyer) — interactive with press + selection animation
// ============================================================================

class _RoleCard extends StatefulWidget {
  final String role;
  final String title;
  final String description;
  final Color accentColor;
  final Color backgroundColor;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.backgroundColor,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    setState(() => _pressed = value);
    if (value) {
      _pressController.forward();
    } else {
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          final scale = 1.0 - _pressController.value;
          return Transform.scale(scale: scale, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? widget.accentColor
                  : widget.accentColor.withValues(alpha: 0.35),
              width: widget.isSelected ? 2.4 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: widget.isSelected ? 0.25 : 0.08),
                blurRadius: widget.isSelected ? 18 : 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar circle
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      widget.accentColor.withValues(alpha: 0.15),
                      widget.accentColor.withValues(alpha: 0.35),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(widget.icon, size: 36, color: widget.accentColor),
              ),
              const SizedBox(width: 16),

              // Text block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: widget.accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Animated arrow button
              _ArrowButton(color: widget.accentColor, pressed: _pressed),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final Color color;
  final bool pressed;
  const _ArrowButton({required this.color, required this.pressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      width: 42,
      height: 42,
      transform: Matrix4.translationValues(pressed ? 4 : 0, 0, 0),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
    );
  }
}

// ============================================================================
// GUEST LINK — subtle bounce-on-tap
// ============================================================================

class _GuestLink extends StatefulWidget {
  final VoidCallback onTap;
  const _GuestLink({required this.onTap});

  @override
  State<_GuestLink> createState() => _GuestLinkState();
}

class _GuestLinkState extends State<_GuestLink> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _dx;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _dx = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0);
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _dx,
        builder: (context, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Continue as Guest',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              Transform.translate(
                offset: Offset(_dx.value, 0),
                child: Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.grey.shade700),
              ),
            ],
          );
        },
      ),
    );
  }
}