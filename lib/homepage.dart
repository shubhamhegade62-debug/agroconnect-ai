import 'dart:math' as math;
import 'package:agroconnect_ai/marketpricescreen.dart';
import 'package:agroconnect_ai/orderscreen.dart';
import 'package:agroconnect_ai/productscreen.dart';
import 'package:agroconnect_ai/profilescreen.dart' show ProfileScreen;
import 'package:flutter/material.dart';
import 'crop_scan_screen.dart';
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
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xffF7FBF9),
      ),
      home: const HomePage(),
    );
  }
}
// ============================================================
// RESPONSIVE BREAKPOINTS
// Mobile   : < 600
// Tablet   : 600 - 1000
// Desktop  : > 1000
// ============================================================
enum ScreenSize { mobile, tablet, desktop }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  late AnimationController pageController;
  late AnimationController pulseController;
  late AnimationController floatController;
  late AnimationController shimmerController;
  late AnimationController rotateController;

  int selectedNav = 0;

  @override
  void initState() {
    super.initState();

    pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..forward();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    // NEW: sweeping shimmer highlight for banners/cards
    shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // NEW: slow continuous rotation used for subtle icon accents
    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    pageController.dispose();
    pulseController.dispose();
    floatController.dispose();
    shimmerController.dispose();
    rotateController.dispose();
    super.dispose();
  }

  // ============================================================
  // ANIMATION HELPERS
  // ============================================================

  Widget animatedItem({
    required Widget child,
    required int delay,
  }) {
    final animation = CurvedAnimation(
      parent: pageController,
      curve: Interval(
        delay / 1250,
        math.min((delay + 460) / 1250, 1),
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
        // NEW: subtle scale-in combined with the existing fade/slide
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
          child: child,
        ),
      ),
    );
  }

  // NEW: reusable shimmer sweep, used on the hero banner
  Widget shimmerOverlay({
    required double width,
    required double height,
    required BorderRadius borderRadius,
  }) {
    return AnimatedBuilder(
      animation: shimmerController,
      builder: (_, _) {
        final t = shimmerController.value;
        return ClipRRect(
          borderRadius: borderRadius,
          child: IgnorePointer(
            child: Align(
              alignment: Alignment(-1 + 2 * t, 0),
              child: Container(
                width: width * 0.4,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: .14),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // RESPONSIVE HELPERS
  // ============================================================

  ScreenSize _screenSize(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 600) return ScreenSize.mobile;
    if (w < 1000) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  bool _isCompact(BuildContext context) =>
      _screenSize(context) == ScreenSize.mobile;

  bool _isDesktop(BuildContext context) =>
      _screenSize(context) == ScreenSize.desktop;

  double _hPad(BuildContext context) {
    switch (_screenSize(context)) {
      case ScreenSize.mobile:
        return 14;
      case ScreenSize.tablet:
        return 24;
      case ScreenSize.desktop:
        return 40;
    }
  }

  // Centers content on very wide screens instead of stretching forever.
  double _maxContentWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return math.min(w, 1200);
  }

  // ============================================================
  // NEW: NAVIGATION HELPER
  // Small central place that pushes to the right screen so every
  // tappable spot on the home page (nav bar, feature buttons,
  // dashboard cards, "View All" links) opens the correct page.
  // ============================================================
  void _openScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ============================================================
  // MAIN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: _maxContentWidth(context),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: animatedItem(delay: 0, child: header()),
                ),
                SliverToBoxAdapter(
                  child: animatedItem(delay: 150, child: aiMedicineTop()),
                ),
                SliverToBoxAdapter(
                  child: animatedItem(delay: 250, child: dashboardCards()),
                ),
                SliverToBoxAdapter(
                  child: animatedItem(
                    delay: 350,
                    child: medicineRecommendation(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: animatedItem(delay: 450, child: featureButtons()),
                ),
                SliverToBoxAdapter(
                  child: animatedItem(delay: 550, child: productsAndPrices()),
                ),
                SliverToBoxAdapter(
                  child: animatedItem(delay: 650, child: aiRecommendation()),
                ),
                SliverToBoxAdapter(
                  child: animatedItem(
                    delay: 750,
                    child: bottomGreenBanner(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _isDesktop(context) ? null : bottomNavigation(),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget header() {
    final size = _screenSize(context);
    final compact = size == ScreenSize.mobile;
    final pad = _hPad(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 188),
      padding: EdgeInsets.fromLTRB(
        pad,
        compact ? 16 : 20,
        pad,
        compact ? 16 : 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffDDF3E8),
            Color(0xffF8FCFA),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // NEW: slow rotating ring behind the avatar
          AnimatedBuilder(
            animation: rotateController,
            builder: (_, child) {
              return Transform.rotate(
                angle: rotateController.value * 2 * math.pi,
                child: child,
              );
            },
            child: _HoverLift(
              child: GestureDetector(
                onTap: () => _openScreen(const ProfileScreen()),
                child: Container(
                  width: compact ? 74 : 100,
                  height: compact ? 74 : 100,
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
                    // counter-rotate the avatar itself so only the ring spins
                    angle: -rotateController.value * 2 * math.pi,
                    child: Container(
                      width: compact ? 68 : 94,
                      height: compact ? 68 : 94,
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
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xff13824C),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: compact ? 10 : 18),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good Morning,",
                  style: TextStyle(
                    fontSize: compact ? 14 : 18,
                    color: const Color(0xff225B47),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        "Shubham Hegade",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact
                              ? 20
                              : (size == ScreenSize.tablet ? 26 : 30),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff075C3A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    AnimatedBuilder(
                      animation: pulseController,
                      builder: (_, child) {
                        return Transform.scale(
                          scale: 1 + pulseController.value * .08,
                          child: Transform.rotate(
                            angle: math.sin(pulseController.value * math.pi) *
                                0.08,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        "🌿",
                        style: TextStyle(fontSize: compact ? 18 : 24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: compact ? 15 : 18,
                      color: const Color(0xff687A73),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "Sangli, Maharashtra",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xff687A73),
                          fontSize: compact ? 11 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedBuilder(
                    animation: pulseController,
                    builder: (_, child) {
                      return Transform.scale(
                        scale: 1 + pulseController.value * .06,
                        child: child,
                      );
                    },
                    child: Icon(
                      Icons.notifications,
                      color: const Color(0xff17684D),
                      size: compact ? 28 : 32,
                    ),
                  ),
                  Positioned(
                    right: -5,
                    top: -7,
                    child: AnimatedBuilder(
                      animation: pulseController,
                      builder: (_, child) {
                        return Transform.scale(
                          scale: 1 + pulseController.value * .18,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          "3",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: floatController,
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      math.sin(floatController.value * math.pi) * 3,
                    ),
                    child: child,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 8 : 12,
                    vertical: compact ? 7 : 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .07),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        "🌤️",
                        style: TextStyle(fontSize: compact ? 19 : 23),
                      ),
                      const SizedBox(width: 5),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "28°C",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Partly Cloudy",
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AI MEDICINE TOP
  // ============================================================

  Widget aiMedicineTop() {
    final compact = _isCompact(context);
    final pad = _hPad(context);

    return Container(
      margin: EdgeInsets.fromLTRB(pad, 8, pad, 14),
      padding: EdgeInsets.all(compact ? 12 : 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff00894B),
            Color(0xff087347),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: .23),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          // NEW: animated shimmer sweep across the hero banner
          Positioned.fill(
            child: LayoutBuilder(
              builder: (_, constraints) => shimmerOverlay(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          Row(
            children: [
              AnimatedBuilder(
                animation: pulseController,
                builder: (_, child) {
                  return Transform.scale(
                    scale: 1 + pulseController.value * .07,
                    child: child,
                  );
                },
                child: Container(
                  width: compact ? 48 : 58,
                  height: compact ? 48 : 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .18),
                  ),
                  child: Icon(
                    Icons.local_florist,
                    color: Colors.white,
                    size: compact ? 28 : 34,
                  ),
                ),
              ),
              SizedBox(width: compact ? 9 : 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AI Crop Health & Medicine Recommendation",
                      maxLines: 2,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Upload crop photo or select crop to get AI suggested medicine and treatment.",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CropScanScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Check Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DASHBOARD CARDS
  // ============================================================

  Widget dashboardCards() {
    final size = _screenSize(context);
    final pad = _hPad(context);

    final cards = [
      infoCard(
        icon: Icons.eco,
        iconColor: const Color(0xff25A65A),
        title: "My Crops",
        value: "3",
        subtitle: "Active Listings",
        arrow: true,
        // NEW: tap wiring
        onTap: () => _openScreen(const ProductsScreen()),
      ),
      infoCard(
        icon: Icons.account_balance_wallet,
        iconColor: const Color(0xffffa726),
        title: "Today's Market Price",
        value: "₹ 25/kg",
        subtitle: "Tomato (Modal)",
        arrow: true,
        onTap: () => _openScreen(const MarketPricesScreen()),
      ),
      infoCard(
        icon: Icons.bar_chart,
        iconColor: const Color(0xff24A557),
        title: "AI Predicted Price",
        value: "₹ 28/kg",
        subtitle: "▲ +12%",
        arrow: true,
        onTap: () => _openScreen(const MarketPricesScreen()),
      ),
      infoCard(
        icon: Icons.cloud,
        iconColor: const Color(0xff4D9CE8),
        title: "Weather Forecast",
        value: "28° / 22°",
        subtitle: "Light Rain",
        arrow: true,
        onTap: () {},
      ),
    ];

    // Mobile: horizontal scroll. Tablet: 2x2 grid. Desktop: single row.
    if (size == ScreenSize.mobile) {
      return SizedBox(
        height: 166,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: pad),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: cards.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, i) => SizedBox(width: 172, child: cards[i]),
        ),
      );
    }

    if (size == ScreenSize.tablet) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 2.2,
          children: cards,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            Expanded(child: cards[i]),
            if (i != cards.length - 1) const SizedBox(width: 14),
          ],
        ],
      ),
    );
  }

  Widget infoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required bool arrow,
    // NEW: optional tap handler so each card can open its own screen
    VoidCallback? onTap,
  }) {
    final compact = _isCompact(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .94, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (_, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      // NEW: gentle hover/press feedback everywhere infoCard is used
      child: _HoverLift(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              height: compact ? 160 : 184,
              padding: EdgeInsets.all(compact ? 11 : 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffE4ECE8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .035),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 40 : 44,
                    height: compact ? 40 : 44,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: .14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: compact ? 23 : 25,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? 11 : 13,
                      color: const Color(0xff164E40),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: compact ? 19 : 22,
                        color: const Color(0xff144D3D),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: subtitle.contains("+")
                                ? Colors.green
                                : Colors.grey,
                            fontSize: compact ? 9 : 10,
                          ),
                        ),
                      ),
                      if (arrow)
                        const Icon(
                          Icons.arrow_forward,
                          size: 17,
                          color: Colors.grey,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MEDICINE RECOMMENDATION
  // ============================================================

  Widget medicineRecommendation() {
    final size = _screenSize(context);
    final compact = size == ScreenSize.mobile;
    final pad = _hPad(context);

    return Container(
      margin: EdgeInsets.fromLTRB(pad, 16, pad, 14),
      padding: EdgeInsets.all(compact ? 11 : 14),
      decoration: BoxDecoration(
        color: const Color(0xffF5FCF7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffC9E6D0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: compact ? 18 : 21,
                backgroundColor: const Color(0xffDDF5E1),
                child: Icon(
                  Icons.eco,
                  color: const Color(0xff178447),
                  size: compact ? 20 : 23,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AI Medicine Recommendation",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff075D3C),
                      ),
                    ),
                    Text(
                      "For Tomato (Leaf Curl Disease)",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),

          // Mobile: stacked. Tablet/Desktop: wide row layout.
          if (compact) _medicineCompactBody() else _medicineWideBody(),
        ],
      ),
    );
  }

  Widget _cropVisual({required double width, required double height}) {
    return AnimatedBuilder(
      animation: floatController,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(
            0,
            math.sin(floatController.value * math.pi) * 2,
          ),
          child: child,
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xffE8F5DE),
              Color(0xffD5EFD0),
            ],
          ),
        ),
        child: const Icon(
          Icons.grass,
          color: Color(0xff58A63D),
          size: 82,
        ),
      ),
    );
  }

  Widget _medicineDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xffDDF4E2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Recommended Medicine",
            style: TextStyle(
              color: Color(0xff168047),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: pulseController,
              builder: (_, child) {
                return Transform.scale(
                  scale: 1 + pulseController.value * .035,
                  child: child,
                );
              },
              child: Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: const Icon(
                  Icons.medication,
                  color: Color(0xff15944F),
                  size: 34,
                ),
              ),
            ),
            const SizedBox(width: 9),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tata Rallis 100 ml",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "(Thiamethoxam 25% WG)",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "💧  Dosage: 2 gm per liter water",
                    style: TextStyle(fontSize: 9),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "📅  Apply: Once in 7 days",
                    style: TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: _HoverLift(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff078345),
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "View Details",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _aiSuggestion() {
    return Container(
      width: 150,
      height: 185,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xffF0FAF2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xffDCF3E1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              "AI Suggestion",
              style: TextStyle(
                color: Color(0xff18834A),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 11),
          const Text(
            "Early treatment can save your crop and increase yield by 20%.",
            style: TextStyle(
              color: Color(0xff235A42),
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: AnimatedBuilder(
              animation: floatController,
              builder: (_, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    -math.sin(floatController.value * math.pi) * 4,
                  ),
                  child: child,
                );
              },
              child: const Text("🌱", style: TextStyle(fontSize: 42)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicineWideBody() {
    // On tablet, shrink the aside panel a bit so nothing overflows.
    final tablet = _screenSize(context) == ScreenSize.tablet;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cropVisual(width: tablet ? 120 : 145, height: tablet ? 130 : 142),
        const SizedBox(width: 13),
        Expanded(child: _medicineDetails()),
        const SizedBox(width: 12),
        _aiSuggestion(),
      ],
    );
  }

  Widget _medicineCompactBody() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cropVisual(width: 112, height: 112),
            const SizedBox(width: 10),
            Expanded(child: _medicineDetails()),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: _aiSuggestion()),
      ],
    );
  }

  // ============================================================
  // FEATURE BUTTONS
  // ============================================================

  Widget featureButtons() {
    final size = _screenSize(context);
    final pad = _hPad(context);

    final items = [
      feature(
        icon: Icons.eco,
        color: Colors.green,
        title: "Add Produce",
        subtitle: "Sell your crop",
        // NEW: tap wiring
        onTap: () => _openScreen(const ProductsScreen()),
      ),
      feature(
        icon: Icons.search,
        color: Colors.blue,
        title: "Market Prices",
        subtitle: "Live & History",
        onTap: () => _openScreen(const MarketPricesScreen()),
      ),
      feature(
        icon: Icons.psychology,
        color: Colors.purple,
        title: "AI Prediction",
        subtitle: "Price Forecast",
        onTap: () => _openScreen(const MarketPricesScreen()),
      ),
      feature(
        icon: Icons.groups,
        color: Colors.orange,
        title: "Find Buyers",
        subtitle: "Direct Connect",
        onTap: () => _openScreen(const OrdersScreen()),
      ),
      feature(
        icon: Icons.local_shipping,
        color: Colors.lightBlue,
        title: "Transport",
        subtitle: "Delivery Partner",
        onTap: () => _openScreen(const OrdersScreen()),
      ),
    ];

    if (size == ScreenSize.mobile) {
      return SizedBox(
        height: 145,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: pad),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 9),
          itemBuilder: (_, i) => SizedBox(width: 142, child: items[i]),
        ),
      );
    }

    // Tablet: wrap onto two rows instead of squeezing 5 across.
    if (size == ScreenSize.tablet) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items)
              SizedBox(width: (1000 - pad * 2 - 24) / 3, child: item),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Expanded(child: items[i]),
            if (i != items.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }

  Widget feature({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    // NEW: optional tap handler so each feature button opens its own screen
    VoidCallback? onTap,
  }) {
    final compact = _isCompact(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .88, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.elasticOut,
      builder: (_, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: _HoverLift(
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            child: Container(
              height: compact ? 140 : 158,
              padding: EdgeInsets.all(compact ? 9 : 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xffE3EBE6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .025),
                    blurRadius: 7,
                  ),
                ],
              ),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: pulseController,
                    builder: (_, child) {
                      return Transform.translate(
                        offset: Offset(0, -pulseController.value * 2),
                        child: child,
                      );
                    },
                    child: Container(
                      width: compact ? 45 : 50,
                      height: compact ? 45 : 50,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .13),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: compact ? 26 : 29),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: compact ? 10 : 12,
                      color: const Color(0xff154C3D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 8 : 9,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: color, size: 17),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCTS + MARKET
  // ============================================================

  Widget productsAndPrices() {
    final size = _screenSize(context);
    final pad = _hPad(context);

    if (size == ScreenSize.mobile) {
      return Padding(
        padding: EdgeInsets.fromLTRB(pad, 15, pad, 0),
        child: Column(
          children: [
            sectionCard(
              title: "Your Products",
              icon: Icons.inventory_2,
              child: _productContent(),
              // NEW: tap wiring
              onTap: () => _openScreen(const ProductsScreen()),
            ),
            const SizedBox(height: 12),
            sectionCard(
              title: "Latest Market Prices",
              icon: Icons.bar_chart,
              child: _marketContent(),
              onTap: () => _openScreen(const MarketPricesScreen()),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 18, pad, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: sectionCard(
              title: "Your Products",
              icon: Icons.inventory_2,
              child: _productContent(),
              onTap: () => _openScreen(const ProductsScreen()),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: sectionCard(
              title: "Latest Market Prices",
              icon: Icons.bar_chart,
              child: _marketContent(),
              onTap: () => _openScreen(const MarketPricesScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productContent() {
    final compact = _isCompact(context);

    return Row(
      children: [
        Container(
          width: compact ? 105 : 145,
          height: compact ? 125 : 145,
          decoration: BoxDecoration(
            color: const Color(0xffEFF7EA),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.local_florist,
            color: Colors.red,
            size: 70,
          ),
        ),
        SizedBox(width: compact ? 9 : 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      "Tomato",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 7),
                  Text(
                    "Active",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 9),
              Text("⚖ Quantity: 500 kg", style: TextStyle(fontSize: 10)),
              SizedBox(height: 6),
              Text(
                "₹ Expected Price: ₹25/kg",
                style: TextStyle(fontSize: 10),
              ),
              SizedBox(height: 6),
              Text("◉ Grade: A", style: TextStyle(fontSize: 10)),
              SizedBox(height: 6),
              Text("📍 Location: Sangli", style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _marketContent() {
    return Column(
      children: [
        marketRow("🍅", "Tomato", "Sangli Market", "₹ 24/kg", "+2%"),
        marketRow("🧅", "Onion", "Pune Market", "₹ 32/kg", "+1%"),
        marketRow("🥔", "Potato", "Kolhapur Market", "₹ 28/kg", "+3%"),
      ],
    );
  }

  Widget sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    // NEW: optional tap handler wired to the "View All →" link
    VoidCallback? onTap,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 242),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE0EAE4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xff17854A), size: 22),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff105D42),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              _HoverLift(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onTap,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Text(
                      "View All →",
                      style: TextStyle(
                        color: Color(0xff17854A),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget marketRow(
    String emoji,
    String name,
    String market,
    String price,
    String change,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xffF5F8F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  market,
                  style: const TextStyle(color: Colors.grey, fontSize: 9),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                "▲ $change",
                style: const TextStyle(color: Colors.green, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AI RECOMMENDATION
  // ============================================================

  Widget aiRecommendation() {
    final compact = _isCompact(context);
    final pad = _hPad(context);

    return Container(
      margin: EdgeInsets.fromLTRB(pad, 13, pad, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffEEF8FD),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xffD5EAF3)),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: pulseController,
            builder: (_, child) {
              return Transform.scale(
                scale: 1 + pulseController.value * .08,
                child: child,
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xff2996D6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lightbulb, color: Colors.white),
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Recommendation",
                  style: TextStyle(
                    color: Color(0xff2376A8),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Based on current price and market trend, it is better to WAIT for Tomato.",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xff63737A), fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!compact)
            _HoverLift(
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => _openScreen(const MarketPricesScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Text(
                    "View Prediction →",
                    style: TextStyle(
                      color: Color(0xff23834E),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // GREEN BANNER
  // ============================================================

  Widget bottomGreenBanner() {
    final pad = _hPad(context);

    return AnimatedBuilder(
      animation: floatController,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, -floatController.value * 2),
          child: child,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: pad),
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xff008B48),
              Color(0xff40B82D),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (_, constraints) => shimmerOverlay(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const Row(
              children: [
                Icon(Icons.eco, color: Colors.white, size: 29),
                SizedBox(width: 11),
                Expanded(
                  child: Text(
                    "Healthy Crop  =  Better Yield  =  Higher Profit",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text("🌿", style: TextStyle(fontSize: 34)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomNavigation() {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navItem(icon: Icons.home, title: "Home", index: 0),
          navItem(
            icon: Icons.inventory_2_outlined,
            title: "Products",
            index: 1,
          ),
          navItem(icon: Icons.bar_chart, title: "Market", index: 2),
          navItem(
            icon: Icons.assignment_outlined,
            title: "Orders",
            index: 3,
          ),
          navItem(icon: Icons.person_outline, title: "Profile", index: 4),
        ],
      ),
    );
  }

  Widget navItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final selected = selectedNav == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedNav = index;
        });
        // NEW: every nav item (besides Home) opens its own screen.
        // Selecting Home just keeps you here / highlights the tab.
        switch (index) {
          case 1:
            _openScreen(const ProductsScreen());
            break;
          case 2:
            _openScreen(const MarketPricesScreen());
            break;
          case 3:
            _openScreen(const OrdersScreen());
            break;
          case 4:
            _openScreen(const ProfileScreen());
            break;
          default:
            break;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffE8F7ED) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.18 : 1,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: 24,
                color: selected
                    ? const Color(0xff078448)
                    : const Color(0xff7C8582),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? const Color(0xff078448)
                    : const Color(0xff7C8582),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// NEW: reusable hover/press "lift" wrapper — adds a small scale +
// shadow response on desktop hover and on tap-down, used across
// cards and buttons for extra interactive polish.
// ============================================================
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