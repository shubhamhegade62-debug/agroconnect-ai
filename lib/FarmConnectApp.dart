import 'package:flutter/material.dart';

void main() {
  runApp(const FarmConnectApp());
}

// ============================================================
// APP
// ============================================================

class FarmConnectApp extends StatelessWidget {
  const FarmConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FarmConnect',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FBF9),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
      ),
      home: const ProductDetailsScreen(),
    );
  }
}

// ============================================================
// COLORS
// ============================================================

class AppColors {
  static const primary = Color(0xFF108B4A);
  static const primaryDark = Color(0xFF08723B);

  static const greenText = Color(0xFF146B45);
  static const lightGreen = Color(0xFFE7F8EE);
  static const paleGreen = Color(0xFFF2FAF5);

  static const dark = Color(0xFF183B2D);
  static const grey = Color(0xFF71817A);
  static const lightGrey = Color(0xFFE3ECE7);

  static const orange = Color(0xFFF3B321);
  static const white = Colors.white;
}

// ============================================================
// PRODUCT DETAILS SCREEN
// ============================================================

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  int _selectedBottomIndex = 1;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Animation<double> _fade(double start, double end) {
    return CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        start,
        end,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  Animation<Offset> _slide(double start, double end) {
    return Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          start,
          end,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(),
                  ),

                  SliverToBoxAdapter(
                    child: _animatedSection(
                      0.05,
                      0.30,
                      _buildProductCard(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _animatedSection(
                      0.18,
                      0.40,
                      _buildFarmerCard(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _animatedSection(
                      0.30,
                      0.52,
                      _buildLocationCard(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _animatedSection(
                      0.42,
                      0.64,
                      _buildBuyerOffersHeader(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _animatedSection(
                      0.46,
                      0.70,
                      _buildOfferList(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _animatedSection(
                      0.58,
                      0.80,
                      _buildMakeOfferBanner(),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 18),
                  ),
                ],
              ),
            ),

            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ANIMATION WRAPPER
  // ==========================================================

  Widget _animatedSection(
    double start,
    double end,
    Widget child,
  ) {
    return FadeTransition(
      opacity: _fade(start, end),
      child: SlideTransition(
        position: _slide(start, end),
        child: child,
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 132,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1500382017468-9049fed747ef'
              '?auto=format&fit=crop&w=1200&q=80',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFEAF7EF),
                        Color(0xFFD9F0E1),
                      ],
                    ),
                  ),
                );
              },
              errorBuilder: (_, _, _) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFEAF7EF),
                        Color(0xFFD9F0E1),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: .90),
                    Colors.white.withValues(alpha: .20),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _roundHeaderButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () {},
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Product Details',
                        style: TextStyle(
                          color: AppColors.dark,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Connect directly with verified farmers',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                _roundHeaderButton(
                  icon: Icons.favorite_border_rounded,
                  active: _isFavorite,
                  onTap: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                ),

                const SizedBox(width: 8),

                _roundHeaderButton(
                  icon: Icons.share_outlined,
                  onTap: () {
                    _showMessage('Share product');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: .88),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            color: active
                ? Colors.redAccent
                : AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // PRODUCT CARD
  // ==========================================================

  Widget _buildProductCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 500;

            if (compact) {
              return _buildCompactProductCard();
            }

            return _buildWideProductCard();
          },
        ),
      ),
    );
  }

  Widget _buildCompactProductCard() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTomatoImage(
              width: 142,
              height: 142,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: _buildProductInformation(),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildProductAttributes(),
      ],
    );
  }

  Widget _buildWideProductCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTomatoImage(
          width: 220,
          height: 220,
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProductInformation(),
              const SizedBox(height: 12),
              _buildProductAttributes(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTomatoImage({
    required double width,
    required double height,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1592924357228-91a4daadcfea'
              '?auto=format&fit=crop&w=800&q=85',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFFE4F2E7),
                  child: const Center(
                    child: Text(
                      '🍅',
                      style: TextStyle(fontSize: 70),
                    ),
                  ),
                );
              },
              errorBuilder: (_, _, _) {
                return Container(
                  color: const Color(0xFFE4F2E7),
                  child: const Center(
                    child: Text(
                      '🍅',
                      style: TextStyle(fontSize: 70),
                    ),
                  ),
                );
              },
            ),

            Positioned(
              top: 9,
              left: 9,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Fresh',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .60),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '1/4',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text(
              'Tomato',
              style: TextStyle(
                color: AppColors.dark,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 7),
            const Icon(
              Icons.eco_rounded,
              color: AppColors.primary,
              size: 21,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Available',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 3),

        const Text(
          'Grade A • Fresh Harvest',
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              '₹ 24',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 29,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 3),
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                '/kg',
                style: TextStyle(
                  color: AppColors.dark,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text(
                '▲ +2%',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 2),

        const Text(
          '(Market Price ₹ 22–26/kg)',
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: AppColors.paleGreen,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '500 kg',
                style: TextStyle(
                  color: AppColors.dark,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'Quantity',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductAttributes() {
    return Row(
      children: [
        Expanded(
          child: _attribute(
            icon: Icons.eco_outlined,
            title: 'Organic',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _attribute(
            icon: Icons.verified_outlined,
            title: 'Grade A',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _attribute(
            icon: Icons.calendar_month_outlined,
            title: 'Harvested',
            subtitle: '5 Sep 2025',
          ),
        ),
      ],
    );
  }

  Widget _attribute({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 60,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8F0EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.greenText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.dark,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FARMER CARD
  // ==========================================================

  Widget _buildFarmerCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDFF1E5),
              ),
              child: const Center(
                child: Text(
                  '👨‍🌾',
                  style: TextStyle(fontSize: 45),
                ),
              ),
            ),

            const SizedBox(width: 13),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Ramesh Patil',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.dark,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.verified,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ],
                  ),

                  SizedBox(height: 3),

                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Verified Farmer',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 5),

                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.grey,
                        size: 15,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'Sangli, Maharashtra',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.orange,
                        size: 18,
                      ),
                      SizedBox(width: 3),
                      Text(
                        '4.8',
                        style: TextStyle(
                          color: AppColors.dark,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '(32 reviews)',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            OutlinedButton(
              onPressed: () {
                _showMessage('Opening farmer profile...');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(
                  color: Color(0xFFB8E4CA),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 19,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'View Profile',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // LOCATION + FEATURES
  // ==========================================================

  Widget _buildLocationCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: _cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                15,
                14,
                15,
                13,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.lightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Farmer Location',
                          style: TextStyle(
                            color: AppColors.dark,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Sangli, Maharashtra',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  OutlinedButton.icon(
                    onPressed: () {
                      _showMessage('Opening map...');
                    },
                    icon: const Icon(
                      Icons.map_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'View on Map →',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      backgroundColor: AppColors.paleGreen,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              height: 1,
              color: AppColors.lightGrey,
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: _feature(
                      Icons.eco_outlined,
                      'Best Quality',
                      'Fresh & Natural',
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _feature(
                      Icons.local_shipping_outlined,
                      'Direct from',
                      'Farmer',
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _feature(
                      Icons.verified_user_outlined,
                      'Verified Farmer',
                      'Trust & Safety',
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _feature(
                      Icons.spa_outlined,
                      'Supports',
                      'Local Farmers',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feature(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      height: 94,
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.paleGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 21,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.greenText,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.greenText,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUYER OFFERS HEADER
  // ==========================================================

  Widget _buildBuyerOffersHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        0,
        24,
        9,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.handshake_outlined,
            color: AppColors.primary,
            size: 26,
          ),
          const SizedBox(width: 8),
          const Text(
            'Buyer Offers',
            style: TextStyle(
              color: AppColors.dark,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '3 offers available',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // OFFERS
  // ==========================================================

  Widget _buildOfferList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _offerCard(
            icon: Icons.business_outlined,
            iconBackground: const Color(0xFFE1F5E8),
            company: 'Shree Sai Traders',
            type: 'Wholesaler',
            rating: '4.6',
            reviews: '12 reviews',
            price: '₹ 23/kg',
            quantity: '500 kg',
            location: 'Kolhapur, Maharashtra',
            bestOffer: true,
          ),

          const SizedBox(height: 7),

          _offerCard(
            icon: Icons.restaurant_outlined,
            iconBackground: const Color(0xFFE1F5E8),
            company: 'Green Valley Hotel',
            type: 'Hotel',
            rating: '4.5',
            reviews: '8 reviews',
            price: '₹ 25/kg',
            quantity: '300 kg',
            location: 'Pune, Maharashtra',
          ),

          const SizedBox(height: 7),

          _offerCard(
            icon: Icons.shopping_cart_outlined,
            iconBackground: const Color(0xFFE1F5E8),
            company: 'Fresh Mart',
            type: 'Retailer',
            rating: '4.2',
            reviews: '6 reviews',
            price: '₹ 24/kg',
            quantity: '200 kg',
            location: 'Nashik, Maharashtra',
          ),
        ],
      ),
    );
  }

  Widget _offerCard({
    required IconData icon,
    required Color iconBackground,
    required String company,
    required String type,
    required String rating,
    required String reviews,
    required String price,
    required String quantity,
    required String location,
    bool bestOffer = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4ECE8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 430;

          if (narrow) {
            return _narrowOfferCard(
              icon: icon,
              iconBackground: iconBackground,
              company: company,
              type: type,
              rating: rating,
              reviews: reviews,
              price: price,
              quantity: quantity,
              location: location,
              bestOffer: bestOffer,
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _offerIcon(
                icon,
                iconBackground,
              ),

              const SizedBox(width: 10),

              Expanded(
                flex: 5,
                child: _buyerInformation(
                  company: company,
                  type: type,
                  rating: rating,
                  reviews: reviews,
                ),
              ),

              Container(
                width: 1,
                height: 58,
                color: AppColors.lightGrey,
              ),

              const SizedBox(width: 10),

              Expanded(
                flex: 4,
                child: _offerInformation(
                  price: price,
                  quantity: quantity,
                  location: location,
                  bestOffer: bestOffer,
                ),
              ),

              const SizedBox(width: 10),

              _offerButtons(),
            ],
          );
        },
      ),
    );
  }

  Widget _narrowOfferCard({
    required IconData icon,
    required Color iconBackground,
    required String company,
    required String type,
    required String rating,
    required String reviews,
    required String price,
    required String quantity,
    required String location,
    required bool bestOffer,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _offerIcon(
              icon,
              iconBackground,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buyerInformation(
                company: company,
                type: type,
                rating: rating,
                reviews: reviews,
              ),
            ),
            _offerInformation(
              price: price,
              quantity: quantity,
              location: location,
              bestOffer: bestOffer,
            ),
          ],
        ),

        const SizedBox(height: 9),

        Row(
          children: [
            Expanded(
              child: _acceptButton(),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _messageButton(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _offerIcon(
    IconData icon,
    Color background,
  ) {
    return Container(
      width: 51,
      height: 51,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
        size: 27,
      ),
    );
  }

  Widget _buyerInformation({
    required String company,
    required String type,
    required String rating,
    required String reviews,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          company,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.dark,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          type,
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 10,
          ),
        ),

        const SizedBox(height: 4),

        Row(
          children: [
            const Icon(
              Icons.star_rounded,
              color: AppColors.orange,
              size: 15,
            ),
            const SizedBox(width: 2),
            Text(
              rating,
              style: const TextStyle(
                color: AppColors.dark,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '($reviews)',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _offerInformation({
    required String price,
    required String quantity,
    required String location,
    required bool bestOffer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              price,
              style: const TextStyle(
                color: AppColors.dark,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),

            if (bestOffer) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'Best Offer',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 5),

        Text(
          'Quantity: $quantity',
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 10,
          ),
        ),

        const SizedBox(height: 3),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 13,
              color: AppColors.grey,
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                location,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _offerButtons() {
    return SizedBox(
      width: 128,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _acceptButton(),
          const SizedBox(height: 5),
          _messageButton(),
        ],
      ),
    );
  }

  Widget _acceptButton() {
    return SizedBox(
      height: 35,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _showAcceptDialog();
        },
        icon: const Icon(
          Icons.check_rounded,
          size: 15,
        ),
        label: const Text(
          'Accept Offer',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _messageButton() {
    return SizedBox(
      height: 35,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          _showMessage('Opening buyer chat...');
        },
        icon: const Icon(
          Icons.chat_bubble_outline_rounded,
          size: 15,
        ),
        label: const Text(
          'Message',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: Color(0xFF94D1AD),
          ),
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // MAKE OFFER BANNER
  // ==========================================================

  Widget _buildMakeOfferBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFE9F8EF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFD4EDDD),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),

            const SizedBox(width: 9),

            const Expanded(
              child: Text(
                'Not interested? You can also make your own offer.',
                style: TextStyle(
                  color: AppColors.greenText,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: 7),

            ElevatedButton(
              onPressed: () {
                _showMakeOfferDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Make Offer',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  Widget _buildBottomNavigation() {
    const items = [
      _NavItem(
        icon: Icons.home_rounded,
        label: 'Home',
      ),
      _NavItem(
        icon: Icons.spa_outlined,
        label: 'Products',
      ),
      _NavItem(
        icon: Icons.bar_chart_rounded,
        label: 'Market',
      ),
      _NavItem(
        icon: Icons.assignment_outlined,
        label: 'Orders',
      ),
      _NavItem(
        icon: Icons.person_outline_rounded,
        label: 'Profile',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: List.generate(
              items.length,
              (index) {
                final selected =
                    _selectedBottomIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedBottomIndex = index;
                      });
                    },
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: selected ? 1.08 : 1,
                          duration: const Duration(
                            milliseconds: 200,
                          ),
                          child: Icon(
                            items[index].icon,
                            color: selected
                                ? AppColors.primary
                                : const Color(0xFF89958F),
                            size: 25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(
                            milliseconds: 200,
                          ),
                          style: TextStyle(
                            color: selected
                                ? AppColors.primary
                                : const Color(0xFF89958F),
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w900
                                : FontWeight.w500,
                          ),
                          child: Text(items[index].label),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // DIALOGS
  // ==========================================================

  void _showAcceptDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Accept Offer?',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Are you sure you want to accept this buyer offer?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showMessage(
                  'Offer accepted successfully!',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  void _showMakeOfferDialog() {
    final priceController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Make Your Offer',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Price per kg',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  suffixText: 'kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final priceText = priceController.text.trim();

                if (priceText.isEmpty) {
                  Navigator.pop(dialogContext);
                  _showMessage('Please enter an offer price.');
                  return;
                }

                Navigator.pop(dialogContext);
                _showMessage(
                  'Your offer has been sent successfully!',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send Offer'),
            ),
          ],
        );
      },
    ).then((_) {
      priceController.dispose();
      quantityController.dispose();
    });
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFE4ECE8),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .035),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// ============================================================
// NAV ITEM MODEL
// ============================================================

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}