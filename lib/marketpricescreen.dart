import 'dart:math' as math;
import 'package:flutter/material.dart';

// ============================================================
// MARKET PRICES SCREEN
// ============================================================

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen>
    with TickerProviderStateMixin {
  late AnimationController pageController;
  late AnimationController pulseController;

  String search = "";
  String sortBy = "Trending";
  final sorts = const ["Trending", "Price ↑", "Price ↓", "A–Z"];

  final items = const [
    _MarketItem("🍅", "Tomato", "Sangli Market", 24, .02),
    _MarketItem("🧅", "Onion", "Pune Market", 32, .01),
    _MarketItem("🥔", "Potato", "Kolhapur Market", 28, .03),
    _MarketItem("🌽", "Maize", "Nashik Market", 19, -.015),
    _MarketItem("🥬", "Cabbage", "Sangli Market", 14, .045),
    _MarketItem("🫑", "Capsicum", "Pune Market", 38, -.008),
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
  }

  @override
  void dispose() {
    pageController.dispose();
    pulseController.dispose();
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

  List<_MarketItem> get _filtered {
    var list = items
        .where((e) => e.name.toLowerCase().contains(search.toLowerCase()))
        .toList();
    switch (sortBy) {
      case "Price ↑":
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case "Price ↓":
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case "A–Z":
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      default:
        list.sort((a, b) => b.change.compareTo(a.change));
    }
    return list;
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
              child: animatedItem(delay: 90, child: _searchBar()),
            ),
            SliverToBoxAdapter(
              child: animatedItem(delay: 160, child: _sortRow()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
              sliver: SliverList.separated(
                itemCount: _filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => animatedItem(
                  delay: 230 + i * 60,
                  child: _priceCard(_filtered[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      child: Row(
        children: [
          _CircleBackButton(onTap: () => Navigator.maybePop(context)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Market Prices",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff075C3A),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: pulseController,
            builder: (_, child) => Transform.scale(
              scale: 1 + pulseController.value * .05,
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xffEEF8FD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Live",
                style: TextStyle(
                  color: Color(0xff2376A8),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffE4ECE8)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => search = v),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search crop or market...",
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortRow() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
        scrollDirection: Axis.horizontal,
        itemCount: sorts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = sorts[i];
          final selected = s == sortBy;
          return _HoverLift(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => sortBy = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 14),
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
                  s,
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

  Widget _priceCard(_MarketItem item) {
    final up = item.change >= 0;
    return _HoverLift(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
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
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xffF5F8F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(item.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xff164E40),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.market,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹ ${item.price}/kg",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      up ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 11,
                      color: up ? Colors.green : Colors.red,
                    ),
                    Text(
                      "${(item.change.abs() * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: up ? Colors.green : Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketItem {
  final String emoji;
  final String name;
  final String market;
  final int price;
  final double change;
  const _MarketItem(this.emoji, this.name, this.market, this.price, this.change);
}

class _CircleBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CircleBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
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
          child: const Icon(Icons.arrow_back, color: Color(0xff075C3A), size: 20),
        ),
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