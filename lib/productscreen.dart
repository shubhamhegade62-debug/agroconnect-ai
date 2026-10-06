import 'dart:math' as math;
import 'package:flutter/material.dart';

// ============================================================
// MY CROPS / PRODUCTS SCREEN
// Matches AgroConnect visual language: green gradients, shimmer
// hero, float/pulse micro-animations, hover-lift cards.
// ============================================================

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with TickerProviderStateMixin {
  late AnimationController pageController;
  late AnimationController pulseController;
  late AnimationController floatController;
  late AnimationController shimmerController;

  String activeFilter = "All";
  final filters = const ["All", "Active", "Sold", "Pending"];

  final crops = const [
    _Crop(
      emoji: "🍅",
      name: "Tomato",
      status: "Active",
      quantity: "500 kg",
      price: "₹ 25/kg",
      grade: "A",
      location: "Sangli",
    ),
    _Crop(
      emoji: "🧅",
      name: "Onion",
      status: "Pending",
      quantity: "300 kg",
      price: "₹ 32/kg",
      grade: "B",
      location: "Sangli",
    ),
    _Crop(
      emoji: "🥔",
      name: "Potato",
      status: "Sold",
      quantity: "800 kg",
      price: "₹ 28/kg",
      grade: "A",
      location: "Sangli",
    ),
  ];

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
    floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    pageController.dispose();
    pulseController.dispose();
    floatController.dispose();
    shimmerController.dispose();
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
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
          child: child,
        ),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7FBF9),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: animatedItem(delay: 0, child: _header()),
            ),
            SliverToBoxAdapter(
              child: animatedItem(delay: 100, child: _summaryBanner()),
            ),
            SliverToBoxAdapter(
              child: animatedItem(delay: 180, child: _filterRow()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
              sliver: SliverList.separated(
                itemCount: _filteredCrops.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => animatedItem(
                  delay: 260 + i * 70,
                  child: _cropCard(_filteredCrops[i]),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _HoverLift(
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: const Color(0xff078345),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Add Produce",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  List<_Crop> get _filteredCrops {
    if (activeFilter == "All") return crops;
    return crops.where((c) => c.status == activeFilter).toList();
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
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
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "My Crops",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff075C3A),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xffDDF3E8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${crops.length} Listings",
              style: const TextStyle(
                color: Color(0xff17854A),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff00894B), Color(0xff087347)],
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
          Positioned.fill(
            child: LayoutBuilder(
              builder: (_, c) => shimmerOverlay(
                width: c.maxWidth,
                height: c.maxHeight,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          Row(
            children: [
              AnimatedBuilder(
                animation: pulseController,
                builder: (_, child) => Transform.scale(
                  scale: 1 + pulseController.value * .07,
                  child: child,
                ),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .18),
                  ),
                  child: const Icon(Icons.inventory_2,
                      color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Estimated Value",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "₹ 62,900",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterRow() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          final selected = f == activeFilter;
          return _HoverLift(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => activeFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xff078345) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xff078345)
                        : const Color(0xffE4ECE8),
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xff164E40),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _cropCard(_Crop crop) {
    final statusColor = switch (crop.status) {
      "Active" => Colors.green,
      "Sold" => Colors.blueGrey,
      _ => Colors.orange,
    };

    return _HoverLift(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE4ECE8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: floatController,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, math.sin(floatController.value * math.pi) * 2),
                child: child,
              ),
              child: Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xffEFF7EA),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(crop.emoji, style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        crop.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xff164E40),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: .13),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          crop.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${crop.quantity} · Grade ${crop.grade} · ${crop.location}",
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    crop.price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xff078345),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _Crop {
  final String emoji;
  final String name;
  final String status;
  final String quantity;
  final String price;
  final String grade;
  final String location;

  const _Crop({
    required this.emoji,
    required this.name,
    required this.status,
    required this.quantity,
    required this.price,
    required this.grade,
    required this.location,
  });
}

// Reusable hover/press lift wrapper (same behavior as main.dart's _HoverLift)
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