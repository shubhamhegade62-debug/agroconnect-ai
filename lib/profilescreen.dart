import 'dart:math' as math;
import 'package:flutter/material.dart';

// ============================================================
// PROFILE SCREEN
// ============================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController pageController;
  late AnimationController pulseController;
  late AnimationController rotateController;

  @override
  void initState() {
    super.initState();
    pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    pageController.dispose();
    pulseController.dispose();
    rotateController.dispose();
    super.dispose();
  }

  Widget animatedItem({required Widget child, required int delay}) {
    final animation = CurvedAnimation(
      parent: pageController,
      curve: Interval(
        delay / 900,
        math.min((delay + 400) / 900, 1),
        curve: Curves.easeOutBack,
      ),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7FBF9),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: animatedItem(delay: 0, child: _backRow()),
            ),
            SliverToBoxAdapter(
              child: animatedItem(delay: 80, child: _profileHeader()),
            ),
            SliverToBoxAdapter(
              child: animatedItem(delay: 200, child: _statsRow()),
            ),
            SliverToBoxAdapter(
              child: animatedItem(delay: 300, child: _menuList()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _backRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Row(
        children: [
          _HoverLift(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .06),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back,
                    color: Color(0xff075C3A), size: 20),
              ),
            ),
          ),
          const Spacer(),
          _HoverLift(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.settings_outlined,
                  color: Color(0xff075C3A), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xffDDF3E8), Color(0xffF8FCFA)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: rotateController,
            builder: (_, child) => Transform.rotate(
              angle: rotateController.value * 2 * math.pi,
              child: child,
            ),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xff25A65A).withValues(alpha: .25),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: -rotateController.value * 2 * math.pi,
                child: Container(
                  width: 94,
                  height: 94,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xffD4F0D8),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: .18),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person,
                      size: 48, color: Color(0xff13824C)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Shubham Hegade",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff075C3A),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on,
                  size: 15, color: Color(0xff687A73)),
              const SizedBox(width: 4),
              const Text(
                "Sangli, Maharashtra",
                style: TextStyle(color: Color(0xff687A73), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _HoverLift(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff078345),
                side: const BorderSide(color: Color(0xff078345)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              ),
              child: const Text(
                "Edit Profile",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow() {
    final stats = [
      ("3", "Crops Listed"),
      ("18", "Orders"),
      ("4.8★", "Rating"),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE4ECE8)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: pulseController,
                    builder: (_, child) => Transform.scale(
                      scale: 1 + pulseController.value * .04,
                      child: child,
                    ),
                    child: Text(
                      stats[i].$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: Color(0xff144D3D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stats[i].$2,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (i != stats.length - 1)
              Container(width: 1, height: 32, color: const Color(0xffE4ECE8)),
          ],
        ],
      ),
    );
  }

  Widget _menuList() {
    final items = [
      (Icons.inventory_2_outlined, "My Crops"),
      (Icons.assignment_outlined, "My Orders"),
      (Icons.account_balance_wallet_outlined, "Payments & Earnings"),
      (Icons.local_shipping_outlined, "Transport Partners"),
      (Icons.notifications_outlined, "Notifications"),
      (Icons.help_outline, "Help & Support"),
      (Icons.logout, "Log Out"),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE4ECE8)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++)
            _HoverLift(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  child: Row(
                    children: [
                      Icon(
                        items[i].$1,
                        size: 20,
                        color: items[i].$2 == "Log Out"
                            ? Colors.redAccent
                            : const Color(0xff17854A),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          items[i].$2,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: items[i].$2 == "Log Out"
                                ? Colors.redAccent
                                : const Color(0xff164E40),
                          ),
                        ),
                      ),
                      if (items[i].$2 != "Log Out")
                        const Icon(Icons.arrow_forward_ios,
                            size: 13, color: Colors.grey),
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

class _HoverLift extends StatefulWidget {
  final Widget child;
  const _HoverLift({required this.child});

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final lift = _pressed ? 0.97 : (_hovering ? 1.03 : 1.0);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: lift,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}