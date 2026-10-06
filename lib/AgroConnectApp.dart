
import 'dart:math' as math;
import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff0A8F4D)),
      ),
      home: const ProductsPage(),
    );
  }
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with TickerProviderStateMixin {
  late final AnimationController pageController;
  late final AnimationController pulseController;
  late final AnimationController floatController;

  int selectedCategory = 0;
  int selectedNav = 1;
  int selectedFilter = 0;
  final Set<int> likedProducts = {};

  final List<CategoryItem> categories = const [
    CategoryItem('Tomato', 'assets/products/tomato.jpg', Color(0xff0A9B53)),
    CategoryItem('Onion', 'assets/products/onion.jpg', Color(0xffF4F8F5)),
    CategoryItem('Potato', 'assets/products/potato.jpg', Color(0xffF4F8F5)),
    CategoryItem('Chili', 'assets/products/chili.jpg', Color(0xffF4F8F5)),
    CategoryItem('Brinjal', 'assets/products/brinjal.jpg', Color(0xffF4F8F5)),
    CategoryItem('Others', null, Color(0xffF4F8F5)),
  ];

  final List<ProductItem> products = const [
    ProductItem(
      name: 'Tomato',
      farmer: 'Ramesh Patil',
      location: 'Sangli, Maharashtra',
      quantity: '500 kg available',
      harvested: 'Harvested: 5 Sep 2025',
      price: '₹ 24',
      unit: '/kg',
      grade: 'Grade A',
      image: 'assets/products/tomato.jpg',
      tags: ['Fresh', 'Organic', 'High Quality'],
    ),
    ProductItem(
      name: 'Onion',
      farmer: 'Suresh Gaikwad',
      location: 'Pune, Maharashtra',
      quantity: '800 kg available',
      harvested: 'Harvested: 2 Sep 2025',
      price: '₹ 32',
      unit: '/kg',
      grade: 'Grade A',
      image: 'assets/products/onion.jpg',
      tags: ['Fresh', 'Organic', 'Premium'],
    ),
    ProductItem(
      name: 'Potato',
      farmer: 'Vikram More',
      location: 'Kolhapur, Maharashtra',
      quantity: '1,200 kg available',
      harvested: 'Harvested: 1 Sep 2025',
      price: '₹ 28',
      unit: '/kg',
      grade: 'Grade B',
      image: 'assets/products/potato.jpg',
      tags: ['Fresh', 'Good Quality', 'Bulk Available'],
    ),
    ProductItem(
      name: 'Green Chilli',
      farmer: 'Shital Deshmukh',
      location: 'Nashik, Maharashtra',
      quantity: '400 kg available',
      harvested: 'Harvested: 4 Sep 2025',
      price: '₹ 40',
      unit: '/kg',
      grade: 'Grade A',
      image: 'assets/products/chili.jpg',
      tags: ['Fresh', 'Organic', 'Premium'],
    ),
    ProductItem(
      name: 'Brinjal',
      farmer: 'Prakash Jadhav',
      location: 'Solapur, Maharashtra',
      quantity: '600 kg available',
      harvested: 'Harvested: 3 Sep 2025',
      price: '₹ 22',
      unit: '/kg',
      grade: 'Grade B',
      image: 'assets/products/brinjal.jpg',
      tags: ['Fresh', 'Good Quality', 'Local'],
    ),
  ];

  @override
  void initState() {
    super.initState();

    pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    pageController.dispose();
    pulseController.dispose();
    floatController.dispose();
    super.dispose();
  }

  Animation<double> sectionAnimation(int index) {
    final start = (index * .085).clamp(0.0, .78);
    final end = math.min(start + .30, 1.0);
    return CurvedAnimation(
      parent: pageController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  Widget animatedSection({
    required int index,
    required Widget child,
    Offset begin = const Offset(0, .08),
  }) {
    final animation = sectionAnimation(index);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 600;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: animatedSection(index: 0, child: _header(compact)),
            ),
            SliverToBoxAdapter(
              child: animatedSection(index: 1, child: _searchBar(compact)),
            ),
            SliverToBoxAdapter(
              child: animatedSection(index: 2, child: _categories(compact)),
            ),
            SliverToBoxAdapter(
              child: animatedSection(index: 3, child: _filters(compact)),
            ),
            SliverToBoxAdapter(
              child: animatedSection(
                index: 4,
                child: _availableHeader(compact),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return animatedSection(
                    index: 5 + index,
                    begin: const Offset(0, .10),
                    child: ProductCard(
                      product: products[index],
                      liked: likedProducts.contains(index),
                      onLike: () {
                        setState(() {
                          if (likedProducts.contains(index)) {
                            likedProducts.remove(index);
                          } else {
                            likedProducts.add(index);
                          }
                        });
                      },
                    ),
                  );
                },
                childCount: products.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavigation(compact),
    );
  }

  Widget _header(bool compact) {
    return Container(
      height: compact ? 172 : 190,
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 28,
        15,
        compact ? 18 : 28,
        12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffE5F6F0),
            Color(0xffF7FBF9),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: FieldPainter()),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      AnimatedBuilder(
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
                        child: const AgroLogo(),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'AgroConnect',
                                style: TextStyle(
                                  fontSize: compact ? 26 : 31,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.8,
                                  color: const Color(0xff0A824B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Direct Farmer to Buyer',
                              style: TextStyle(
                                fontSize: compact ? 10 : 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff39735B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedBuilder(
                        animation: pulseController,
                        builder: (_, child) {
                          return Transform.scale(
                            scale: 1 + pulseController.value * .05,
                            child: child,
                          );
                        },
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Color(0xff185F49),
                          size: 26,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      top: -5,
                      child: Container(
                        width: 21,
                        height: 21,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xffEF5656),
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xff16864D),
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          'B',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      if (!compact) const SizedBox(width: 7),
                      if (!compact)
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buyer',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Color(0xff244F43),
                              ),
                            ),
                            Text(
                              'ABC Foods',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xff3A5B50),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 1,
            child: SizedBox(
              height: compact ? 56 : 65,
              child: CustomPaint(painter: FieldPainter()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(bool compact) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 25,
        10,
        compact ? 16 : 25,
        12,
      ),
      child: Material(
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: compact ? 60 : 68,
          padding: const EdgeInsets.only(left: 16, right: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: Color(0xff15774F),
                size: 29,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Search for crops, farmers or products...',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xff7E8790),
                    fontSize: 15,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: compact ? 46 : 52,
                  height: compact ? 46 : 52,
                  decoration: const BoxDecoration(
                    color: Color(0xffF0FAF4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Color(0xff19804F),
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categories(bool compact) {
    return SizedBox(
      height: compact ? 112 : 120,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 25),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = categories[index];
          final selected = selectedCategory == index;

          return GestureDetector(
            onTap: () => setState(() => selectedCategory = index),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: .94, end: selected ? 1.0 : .97),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              builder: (_, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: compact ? 100 : 108,
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xff0A9950) : Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: selected
                        ? const Color(0xff0A9950)
                        : const Color(0xffE5ECE8),
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: .18),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withValues(alpha: .18)
                            : item.bg,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: item.image != null
                          ? Image.asset(
                              item.image!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.eco_rounded,
                              color: Color(0xff4E9D63),
                              size: 37,
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xff235C4A),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filters(bool compact) {
    return SizedBox(
      height: 67,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 25),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _filterPill(
            text: 'All',
            selected: selectedFilter == 0,
            onTap: () => setState(() => selectedFilter = 0),
          ),
          _filterPill(
            text: 'Price: Low to High',
            icon: Icons.keyboard_arrow_down_rounded,
            selected: selectedFilter == 1,
            onTap: () => setState(() => selectedFilter = 1),
            width: compact ? 184 : 196,
          ),
          _filterPill(
            text: 'Location',
            icon: Icons.keyboard_arrow_down_rounded,
            selected: selectedFilter == 2,
            onTap: () => setState(() => selectedFilter = 2),
            width: 118,
          ),
          _filterPill(
            text: 'Quality',
            icon: Icons.keyboard_arrow_down_rounded,
            selected: selectedFilter == 3,
            onTap: () => setState(() => selectedFilter = 3),
            width: 112,
          ),
          _filterPill(
            text: 'More Filters',
            icon: Icons.filter_alt_outlined,
            selected: selectedFilter == 4,
            onTap: () => setState(() => selectedFilter = 4),
            width: 142,
          ),
        ],
      ),
    );
  }

  Widget _filterPill({
    required String text,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
    double? width,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: width ?? 68,
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: selected ? const Color(0xff0A9950) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? const Color(0xff0A9950)
                  : const Color(0xffDFE8E3),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: .16),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : const Color(0xff476259),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 6),
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? Colors.white
                      : const Color(0xff536A61),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _availableHeader(bool compact) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 27,
        4,
        compact ? 18 : 27,
        8,
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: floatController,
            builder: (_, child) {
              return Transform.rotate(
                angle: math.sin(floatController.value * math.pi) * .06,
                child: child,
              );
            },
            child: const Icon(
              Icons.eco_rounded,
              color: Color(0xff159255),
              size: 34,
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              'Available Products',
              style: TextStyle(
                color: Color(0xff174F41),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Text(
            '125 results found',
            style: TextStyle(
              color: Color(0xff7B858C),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigation(bool compact) {
    return Container(
      height: compact ? 76 : 82,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xffE2E9E5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, 'Home', 0),
            _navItem(Icons.search_rounded, 'Products', 1),
            _navItem(Icons.show_chart_rounded, 'Market Price', 2),
            _navItem(Icons.assignment_outlined, 'Orders', 3),
            _navItem(Icons.person_outline_rounded, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String title, int index) {
    final selected = selectedNav == index;

    return GestureDetector(
      onTap: () => setState(() => selectedNav = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffEAF8EF) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.16 : 1,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: 26,
                color: selected
                    ? const Color(0xff0A8B4C)
                    : const Color(0xff7C8790),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                color: selected
                    ? const Color(0xff0A8B4C)
                    : const Color(0xff7C8790),
                fontSize: 9,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final ProductItem product;
  final bool liked;
  final VoidCallback onLike;

  const ProductCard({
    super.key,
    required this.product,
    required this.liked,
    required this.onLike,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController buttonController;

  @override
  void initState() {
    super.initState();
    buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 170),
      lowerBound: .92,
      upperBound: 1,
      value: 1,
    );
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 600;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 14 : 25,
        4,
        compact ? 14 : 25,
        9,
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 183),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffDDE8E2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .045),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _productImage(compact),
            const SizedBox(width: 11),
            Expanded(
              child: _productDetails(compact),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productImage(bool compact) {
    return SizedBox(
      width: compact ? 181 : 220,
      height: compact ? 158 : 176,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.asset(
                widget.product.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: const BoxDecoration(
                color: Color(0xff12894F),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13),
                  bottomRight: Radius.circular(11),
                ),
              ),
              child: Text(
                widget.product.grade,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productDetails(bool compact) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: TextStyle(
                  color: const Color(0xff173F36),
                  fontSize: compact ? 17 : 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              _metaRow(Icons.person_outline_rounded, widget.product.farmer),
              const SizedBox(height: 5),
              _metaRow(
                Icons.location_on_outlined,
                widget.product.location,
              ),
              const SizedBox(height: 6),
              _metaRow(
                Icons.shopping_bag_outlined,
                widget.product.quantity,
              ),
              const SizedBox(height: 5),
              _metaRow(
                Icons.calendar_today_outlined,
                widget.product.harvested,
              ),
              const SizedBox(height: 7),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.product.price,
                    style: TextStyle(
                      color: const Color(0xff087D45),
                      fontSize: compact ? 23 : 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      widget.product.unit,
                      style: const TextStyle(
                        color: Color(0xff37584D),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffE9F8EE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Negotiable',
                      style: TextStyle(
                        color: Color(0xff4B9B65),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 5,
                runSpacing: 4,
                children: [
                  for (int i = 0; i < widget.product.tags.length; i++)
                    _tag(widget.product.tags[i], i),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTapDown: (_) => buttonController.reverse(),
                  onTapUp: (_) {
                    buttonController.forward();
                    _showDetails(context);
                  },
                  onTapCancel: () => buttonController.forward(),
                  child: ScaleTransition(
                    scale: buttonController,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff078B4B),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: .17),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: widget.onLike,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                widget.liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(widget.liked),
                color: widget.liked
                    ? const Color(0xffE64D64)
                    : const Color(0xff829099),
                size: 27,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _metaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: const Color(0xff738189),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xff68777D),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tag(String text, int index) {
    final backgrounds = const [
      Color(0xffE8F8ED),
      Color(0xffEAF8F0),
      Color(0xffE9F4FF),
      Color(0xffF1EAFE),
      Color(0xfffff0dc),
    ];

    final textColors = const [
      Color(0xff48A169),
      Color(0xff3D9C68),
      Color(0xff4A93C7),
      Color(0xff8A68B9),
      Color(0xffC88737),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgrounds[index % backgrounds.length],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColors[index % textColors.length],
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff174F41),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.product.price}${widget.product.unit} • ${widget.product.quantity}',
                  style: const TextStyle(
                    color: Color(0xff4C675E),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${widget.product.farmer} • ${widget.product.location}',
                  style: const TextStyle(
                    color: Color(0xff718078),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CategoryItem {
  final String name;
  final String? image;
  final Color bg;

  const CategoryItem(this.name, this.image, this.bg);
}

class ProductItem {
  final String name;
  final String farmer;
  final String location;
  final String quantity;
  final String harvested;
  final String price;
  final String unit;
  final String grade;
  final String image;
  final List<String> tags;

  const ProductItem({
    required this.name,
    required this.farmer,
    required this.location,
    required this.quantity,
    required this.harvested,
    required this.price,
    required this.unit,
    required this.grade,
    required this.image,
    required this.tags,
  });
}

class AgroLogo extends StatelessWidget {
  const AgroLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 62,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 2,
            right: 11,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xffFFB51E),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Icon(
            Icons.eco_rounded,
            size: 61,
            color: Color(0xff15924F),
          ),
          Positioned(
            left: 30,
            top: 27,
            child: Container(
              width: 4,
              height: 27,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .8),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xffDCEFF2);
    final sky = Path()
      ..moveTo(0, size.height * .68)
      ..quadraticBezierTo(
        size.width * .22,
        size.height * .42,
        size.width * .44,
        size.height * .64,
      )
      ..quadraticBezierTo(
        size.width * .68,
        size.height * .28,
        size.width,
        size.height * .58,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(sky, paint);

    paint.color = const Color(0xffB9DFB6);
    final hills = Path()
      ..moveTo(0, size.height * .73)
      ..quadraticBezierTo(
        size.width * .20,
        size.height * .52,
        size.width * .38,
        size.height * .72,
      )
      ..quadraticBezierTo(
        size.width * .60,
        size.height * .46,
        size.width,
        size.height * .70,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hills, paint);

    paint.color = const Color(0xff92C983);
    final field = Path()
      ..moveTo(0, size.height * .82)
      ..quadraticBezierTo(
        size.width * .35,
        size.height * .67,
        size.width * .70,
        size.height * .80,
      )
      ..quadraticBezierTo(
        size.width * .86,
        size.height * .72,
        size.width,
        size.height * .79,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(field, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
