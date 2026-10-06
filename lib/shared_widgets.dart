// TODO Implement this library.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Animated text field with focus-based label color + border animation
class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? trailing;
  final TextInputType? keyboardType;

  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.trailing,
    this.keyboardType,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
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
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
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
                    color:
                        _focused ? AppColors.primaryGreen : AppColors.textDark,
                  ),
                  child: Text(widget.label),
                ),
                TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  style:
                      const TextStyle(fontSize: 15, color: AppColors.textDark),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle:
                        const TextStyle(color: AppColors.textGrey, fontSize: 14),
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
class AnimatedEyeIcon extends StatelessWidget {
  final AnimationController controller;
  final bool obscured;
  final VoidCallback onTap;

  const AnimatedEyeIcon({
    super.key,
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
              obscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
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
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const PressableScale({super.key, required this.child, required this.onTap});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
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

/// Primary gradient action button (used for Login / Register submit)
class PrimaryGradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  const PrimaryGradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<PrimaryGradientButton> createState() => _PrimaryGradientButtonState();
}

class _PrimaryGradientButtonState extends State<PrimaryGradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    lowerBound: 0.0,
    upperBound: 0.06,
  );

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.isLoading) return;
    await _pressController.forward();
    await _pressController.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          final scale = 1 - _pressController.value;
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
                color: AppColors.darkGreen.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.icon, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        widget.label,
                        style: const TextStyle(
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
}

/// AgroConnect logo lockup with a gentle bobbing animation
class AnimatedLogo extends StatelessWidget {
  final AnimationController leafController;
  const AnimatedLogo({super.key, required this.leafController});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: leafController,
          builder: (context, child) {
            final bob = math.sin(leafController.value * 2 * math.pi) * 3;
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
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
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
}

/// Simple leaf cluster drawn with icons (top-left corner decoration)
class LeafCluster extends StatelessWidget {
  final double size;
  const LeafCluster({super.key, required this.size});

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
              child: Icon(Icons.eco,
                  color: AppColors.mediumGreen.withValues(alpha: 0.55),
                  size: size * 0.55),
            ),
          ),
          Positioned(
            left: 20,
            top: -5,
            child: Transform.rotate(
              angle: 0.3,
              child: Icon(Icons.eco,
                  color: AppColors.primaryGreen.withValues(alpha: 0.4),
                  size: size * 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stylized farmer illustration (turban + face + shirt silhouette).
/// Replace with Image.asset('assets/farmer.png') if you have the source art.
class FarmerIllustration extends StatelessWidget {
  const FarmerIllustration({super.key});

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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(36)),
              border: Border.all(color: const Color(0xFFE0D8C0)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Icon(Icons.smartphone,
                  color: AppColors.textGrey.withValues(alpha: 0.6), size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

/// Static decorative footer strip resembling rolling farmland
class FarmlandFooter extends StatelessWidget {
  const FarmlandFooter({super.key});

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
    final paint1 = Paint()..color = AppColors.lightGreen.withValues(alpha: 0.5);
    final paint2 = Paint()..color = AppColors.lightGreen.withValues(alpha: 0.8);

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
class CurveClipper extends CustomClipper<Path> {
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