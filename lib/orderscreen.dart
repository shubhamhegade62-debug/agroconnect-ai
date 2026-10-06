import 'dart:math' as math;
import 'package:flutter/material.dart';

// ============================================================
// ORDERS SCREEN
// ============================================================

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late AnimationController pageController;
  late AnimationController pulseController;

  int tab = 0;
  final tabs = const ["Pending", "Completed", "Cancelled"];

  final orders = const [
    _Order("ORD-1042", "Tomato · 200kg", "Ramesh Traders", "₹ 5,000", "Pending"),
    _Order("ORD-1039", "Onion · 150kg", "Kisan Mandi Co.", "₹ 4,800", "Pending"),
    _Order("ORD-1031", "Potato · 400kg", "Fresh Foods Pvt Ltd", "₹ 11,200", "Completed"),
    _Order("ORD-1022", "Tomato · 100kg", "Ramesh Traders", "₹ 2,500", "Completed"),
    _Order("ORD-1015", "Cabbage · 80kg", "Green Basket", "₹ 1,120", "Cancelled"),
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

  List<_Order> get _filtered =>
      orders.where((o) => o.status == tabs[tab]).toList();

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
              child: animatedItem(delay: 100, child: _segmentedTabs()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
              sliver: _filtered.isEmpty
                  ? SliverToBoxAdapter(child: _emptyState())
                  : SliverList.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => animatedItem(
                        delay: 200 + i * 70,
                        child: _orderCard(_filtered[i]),
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
              "Orders",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff075C3A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmentedTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xffEFF4F1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            for (int i = 0; i < tabs.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => tab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tab == i ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: tab == i
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .06),
                                blurRadius: 8,
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      tabs[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: tab == i
                            ? const Color(0xff078345)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: pulseController,
            builder: (_, child) => Transform.scale(
              scale: 1 + pulseController.value * .05,
              child: child,
            ),
            child: const Text("📦", style: TextStyle(fontSize: 52)),
          ),
          const SizedBox(height: 12),
          Text(
            "No ${tabs[tab].toLowerCase()} orders",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(_Order order) {
    final statusColor = switch (order.status) {
      "Pending" => Colors.orange,
      "Completed" => Colors.green,
      _ => Colors.redAccent,
    };

    return _HoverLift(
      child: Container(
        padding: const EdgeInsets.all(13),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  order.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xff164E40),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order.item,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              order.buyer,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  order.amount,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xff078345),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios,
                    size: 13, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Order {
  final String id;
  final String item;
  final String buyer;
  final String amount;
  final String status;
  const _Order(this.id, this.item, this.buyer, this.amount, this.status);
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