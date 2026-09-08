// TODO Implement this library.
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _tractorController;
  late final AnimationController _sceneController;
  late final AnimationController _buttonController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _tractorX; // 0 -> 1 across the road
  late final Animation<double> _sceneFade;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

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

    // --- Tractor: drives in from the left, then idles with a tiny bounce loop ---
    _tractorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _tractorX = CurvedAnimation(
      parent: _tractorController,
      curve: Curves.easeOutCubic,
    );

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

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _tractorController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _sceneController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _tractorController.dispose();
    _sceneController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF1F5B3A);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD9ECF5), Color(0xFFF7FAF7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ---------- LOGO ----------
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: _AgroLogo(color: brandGreen),
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
                  animation: _tractorController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _RoadPainter(),
                      child: Align(
                        alignment: Alignment(
                          -1.0 + _tractorX.value * 1.4, // slides in from off-screen left
                          0.4,
                        ),
                        child: _BouncingTractor(controller: _tractorController),
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
                        child: CustomPaint(
                          painter: _FarmScenePainter(),
                          child: const SizedBox(width: double.infinity, height: double.infinity),
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
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 500),
                              pageBuilder: (_, anim, _) => const HomeScreen(),
                              transitionsBuilder: (_, anim, _, child) => FadeTransition(
                                opacity: anim,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: const Text('Get Started'),
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
      ),
    );
  }
}

/// Circular leaf/plant logo mark, drawn with CustomPaint so it scales
/// crisply at any resolution (no external asset needed).
class _AgroLogo extends StatelessWidget {
  final Color color;
  const _AgroLogo({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 4),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(20),
      child: CustomPaint(
        painter: _LeafPainter(color: color),
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

    // stem
    final stemPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx, size.height * 0.1),
      Offset(center.dx, size.height * 0.9),
      stemPaint,
    );

    // four leaves around the stem
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
  bool shouldRepaint(covariant _LeafPainter oldDelegate) => false;
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

/// Tractor emoji-style icon with a subtle idle bounce once it "arrives".
class _BouncingTractor extends StatelessWidget {
  final AnimationController controller;
  const _BouncingTractor({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final bounce = controller.isCompleted
            ? math.sin(DateTime.now().millisecondsSinceEpoch / 250) * 2
            : 0.0;
        return Transform.translate(
          offset: Offset(0, bounce),
          child: child,
        );
      },
      child: const Icon(Icons.agriculture, size: 46, color: Color(0xFFD35400)),
    );
  }
}

/// Hand-drawn style farm landscape: mountains, sun-lit sky, a house,
/// trees and a striped field — all vector shapes, no image assets.
class _FarmScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // sky
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFEFF6EF),
    );

    // mountains (back layer, lighter)
    _mountain(canvas, w, h, 0.15, h * 0.55, 90, const Color(0xFFB9C6C2));
    _mountain(canvas, w, h, 0.55, h * 0.50, 110, const Color(0xFFA9B8B2));
    _mountain(canvas, w, h, 0.85, h * 0.58, 80, const Color(0xFFC4D0CB));

    // field (bottom half, striped like tilled soil)
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

    // tree
    canvas.drawCircle(Offset(w * 0.18, fieldTop - 22), 26, Paint()..color = const Color(0xFF3F7D45));
    canvas.drawCircle(Offset(w * 0.78, fieldTop - 15), 30, Paint()..color = const Color(0xFF4E8C4E));

    // house
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
  bool shouldRepaint(covariant _FarmScenePainter oldDelegate) => false;
}