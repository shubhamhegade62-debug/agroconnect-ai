// AgroConnect AI — animated splash screen
import 'package:agroconnect_ai/agro.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ----- one-shot entrance controllers -----
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _tractorController;
  late final AnimationController _sceneController;
  late final AnimationController _buttonController;

  // ----- continuous / looping controllers -----
  late final AnimationController _idleController; // tractor bounce + button pulse
  late final AnimationController _ambientController; // clouds drifting, sun rays, smoke

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _tractorX; // 0 -> 1 across the road
  late final Animation<double> _sceneFade;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;
  late final Animation<double> _buttonPulse;

  bool _tractorArrived = false;

  @override
  void initState() {
    super.initState();

    // --- Logo: pop in with a slight overshoot ---
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    // --- Title + subtitle: slide up & fade ---
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));
    _titleFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);
    _subtitleFade = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    // --- Tractor: drives in from the left ---
    _tractorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _tractorX = CurvedAnimation(
      parent: _tractorController,
      curve: Curves.easeOutCubic,
    );
    _tractorController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _tractorArrived = true);
      }
    });

    // --- Farm scene: fades + rises in ---
    _sceneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _sceneFade = CurvedAnimation(parent: _sceneController, curve: Curves.easeIn);

    // --- Button: fades + slides up last ---
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonFade = CurvedAnimation(parent: _buttonController, curve: Curves.easeIn);
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeOutCubic));

    // --- Idle loop: tractor bounce + button breathing pulse (runs forever) ---
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _buttonPulse = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    // --- Ambient loop: drifting clouds, rotating sun rays, tractor smoke ---
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _tractorController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _sceneController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _buttonController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _tractorController.dispose();
    _sceneController.dispose();
    _buttonController.dispose();
    _idleController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF1F5B3A);

    return Scaffold(
      body: Stack(
        children: [
          // ---------- ANIMATED BACKGROUND ----------
          AnimatedBuilder(
            animation: _ambientController,
            builder: (context, _) {
              return CustomPaint(
                painter: _SkyPainter(progress: _ambientController.value),
                size: Size.infinite,
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ---------- LOGO ----------
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: _AgroLogo(color: brandGreen, pulse: _idleController),
                  ),
                ),

                const SizedBox(height: 20),

                // ---------- TITLE ----------
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: const Text(
                      'AgroConnect AI',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: brandGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                FadeTransition(
                  opacity: _subtitleFade,
                  child: const Text(
                    'Smart Farming, Better Future',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ),

                const SizedBox(height: 18),

                // ---------- TRACTOR ON A ROAD ----------
                SizedBox(
                  height: 70,
                  width: double.infinity,
                  child: AnimatedBuilder(
                    animation: Listenable.merge(
                        [_tractorController, _idleController, _ambientController]),
                    builder: (context, child) {
                      // subtle up/down bounce once the tractor has arrived
                      final bounce =
                          _tractorArrived ? (_idleController.value - 0.5) * 4 : 0.0;
                      return CustomPaint(
                        painter: _RoadPainter(),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment(
                                -1.0 + _tractorX.value * 1.4,
                                0.4,
                              ),
                              child: Transform.translate(
                                offset: Offset(0, bounce),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Icon(Icons.agriculture,
                                        size: 46, color: Color(0xFFD35400)),
                                    if (_tractorArrived)
                                      Positioned(
                                        top: -18,
                                        left: 8,
                                        child: _SmokePuff(
                                            progress: _ambientController.value),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // ---------- FARM SCENE ----------
                Expanded(
                  child: FadeTransition(
                    opacity: _sceneFade,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _sceneController,
                        curve: Curves.easeOut,
                      )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedBuilder(
                            animation: _ambientController,
                            builder: (context, _) => CustomPaint(
                              painter:
                                  _FarmScenePainter(progress: _ambientController.value),
                              child: const SizedBox(
                                  width: double.infinity, height: double.infinity),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ---------- GET STARTED BUTTON ----------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SlideTransition(
                    position: _buttonSlide,
                    child: FadeTransition(
                      opacity: _buttonFade,
                      child: AnimatedBuilder(
                        animation: _buttonPulse,
                        builder: (context, child) => Transform.scale(
                          scale: _buttonPulse.value,
                          child: child,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 500),
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      const AgroApp(),
                                  transitionsBuilder:
                                      (context, animation, secondaryAnimation, child) =>
                                          FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                FadeTransition(
                  opacity: _buttonFade,
                  child: const Text(
                    'Made for Farmers, By Technology',
                    style: TextStyle(fontSize: 11, color: Colors.black38),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular leaf/plant logo mark with a slow idle "breathing" pulse.
class _AgroLogo extends StatelessWidget {
  final Color color;
  final Animation<double> pulse;
  const _AgroLogo({required this.color, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final scale = 1.0 + (pulse.value - 0.5) * 0.04;
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 4),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: CustomPaint(
          painter: _LeafPainter(color: color),
        ),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  final Color color;
  _LeafPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = color;
    final paintLight = Paint()..color = color.withValues(alpha: 0.55);
    final center = Offset(size.width / 2, size.height / 2);

    final stemPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx, size.height * 0.1),
      Offset(center.dx, size.height * 0.9),
      stemPaint,
    );

    _drawLeaf(canvas, center + Offset(-size.width * 0.28, -size.height * 0.15),
        paintDark, -0.5);
    _drawLeaf(canvas, center + Offset(size.width * 0.28, -size.height * 0.15),
        paintLight, 0.5);
    _drawLeaf(canvas, center + Offset(-size.width * 0.28, size.height * 0.25),
        paintLight, -2.6);
    _drawLeaf(canvas, center + Offset(size.width * 0.28, size.height * 0.25),
        paintDark, 2.6);
  }

  void _drawLeaf(Canvas canvas, Offset pos, Paint paint, double angle) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    final rect = Rect.fromCenter(center: Offset.zero, width: 34, height: 18);
    canvas.drawOval(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LeafPainter oldDelegate) => oldDelegate.color != color;
}

/// Simple dirt road strip the tractor "drives" along.
class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFB08655);
    final y = size.height * 0.62;
    canvas.drawRect(Rect.fromLTWH(0, y, size.width, 6), paint);
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) => false;
}

/// Small looping puff of smoke that rises and fades from the tractor's exhaust.
class _SmokePuff extends StatelessWidget {
  final double progress; // 0..1, loops
  const _SmokePuff({required this.progress});

  @override
  Widget build(BuildContext context) {
    // three staggered puffs riding the same 0..1 cycle
    return SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        children: List.generate(3, (i) {
          final t = (progress + i * 0.33) % 1.0;
          final riseY = -t * 20;
          final drift = math.sin(t * math.pi * 2) * 3;
          final opacity = (1 - t).clamp(0.0, 1.0) * 0.5;
          final size = 6.0 + t * 8;
          return Positioned(
            left: 10 + drift,
            top: riseY,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Full-bleed sky background: gentle gradient + drifting clouds + a slowly
/// rotating sun so the splash screen feels alive even once entrances finish.
class _SkyPainter extends CustomPainter {
  final double progress; // 0..1, loops every 12s
  _SkyPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    final gradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD9ECF5), Color(0xFFF7FAF7)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), gradient);

    // sun with slowly rotating rays, tucked in the top-right
    final sunCenter = Offset(w * 0.85, h * 0.08);
    final rayPaint = Paint()
      ..color = const Color(0xFFFFE8A3)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(sunCenter.dx, sunCenter.dy);
    canvas.rotate(progress * 2 * math.pi);
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final start = Offset(math.cos(angle) * 22, math.sin(angle) * 22);
      final end = Offset(math.cos(angle) * 30, math.sin(angle) * 30);
      canvas.drawLine(start, end, rayPaint);
    }
    canvas.restore();
    canvas.drawCircle(sunCenter, 18, Paint()..color = const Color(0xFFFFD873));

    // two clouds drifting slowly left-to-right, wrapping around
    _cloud(canvas, ((progress * 0.6 + 0.1) % 1.2 - 0.1) * w, h * 0.16, 1.0);
    _cloud(canvas, ((progress * 0.4 + 0.6) % 1.2 - 0.1) * w, h * 0.24, 0.7);
  }

  void _cloud(Canvas canvas, double x, double y, double scale) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    canvas.drawCircle(Offset(x, y), 14 * scale, paint);
    canvas.drawCircle(Offset(x + 14 * scale, y - 4 * scale), 12 * scale, paint);
    canvas.drawCircle(Offset(x + 26 * scale, y), 14 * scale, paint);
    canvas.drawRect(
      Rect.fromLTWH(x - 2, y, 32 * scale, 10 * scale),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Hand-drawn style farm landscape: mountains, sun-lit sky, a house,
/// trees, a striped field, and a slow-swaying tree canopy.
class _FarmScenePainter extends CustomPainter {
  final double progress; // 0..1, loops
  _FarmScenePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFEFF6EF),
    );

    _mountain(canvas, w, h, 0.15, h * 0.55, 90, const Color(0xFFB9C6C2));
    _mountain(canvas, w, h, 0.55, h * 0.50, 110, const Color(0xFFA9B8B2));
    _mountain(canvas, w, h, 0.85, h * 0.58, 80, const Color(0xFFC4D0CB));

    final fieldTop = h * 0.62;
    canvas.drawRect(
      Rect.fromLTWH(0, fieldTop, w, h - fieldTop),
      Paint()..color = const Color(0xFF6FA45A),
    );
    final stripePaint = Paint()
      ..color = const Color(0xFF5D9450)
      ..strokeWidth = 2;
    for (double y = fieldTop + 8; y < h; y += 10) {
      canvas.drawLine(Offset(0, y), Offset(w, y), stripePaint);
    }

    // trees sway gently left-right
    final sway = math.sin(progress * 2 * math.pi) * 3;
    canvas.save();
    canvas.translate(w * 0.18, fieldTop - 22);
    canvas.rotate(sway * math.pi / 180);
    canvas.drawCircle(Offset.zero, 26, Paint()..color = const Color(0xFF3F7D45));
    canvas.restore();

    canvas.save();
    canvas.translate(w * 0.78, fieldTop - 15);
    canvas.rotate(-sway * math.pi / 180);
    canvas.drawCircle(Offset.zero, 30, Paint()..color = const Color(0xFF4E8C4E));
    canvas.restore();

    final houseLeft = w * 0.30;
    final houseTop = fieldTop - 45;
    canvas.drawRect(
      Rect.fromLTWH(houseLeft, houseTop, 70, 45),
      Paint()..color = const Color(0xFFF3E3C3),
    );
    final roofPath = Path()
      ..moveTo(houseLeft - 8, houseTop)
      ..lineTo(houseLeft + 35, houseTop - 28)
      ..lineTo(houseLeft + 78, houseTop)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = const Color(0xFFB5522E));
  }

  void _mountain(Canvas canvas, double w, double h, double xFrac, double baseY,
      double height, Color color) {
    final cx = w * xFrac;
    final path = Path()
      ..moveTo(cx - 70, baseY)
      ..lineTo(cx, baseY - height)
      ..lineTo(cx + 70, baseY)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _FarmScenePainter oldDelegate) =>
      oldDelegate.progress != progress;
}