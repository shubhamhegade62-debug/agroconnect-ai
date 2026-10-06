import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const FarmFreshApp());
}

class FarmFreshApp extends StatelessWidget {
  const FarmFreshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farm Fresh',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF8FCFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF159447),
        ),
      ),
      home: const ProduceDetailsPage(),
    );
  }
}

// ------------------------------------------------------------
// COLORS
// ------------------------------------------------------------

class AppColors {
  static const green = Color(0xFF118B46);
  static const darkGreen = Color(0xFF08783B);
  static const lightGreen = Color(0xFFE8F8EE);
  static const veryLightGreen = Color(0xFFF2FBF5);

  static const textDark = Color(0xFF193C2D);
  static const textGrey = Color(0xFF6B7F77);
  static const border = Color(0xFFE1EDE6);

  static const white = Colors.white;
  static const background = Color(0xFFF8FCFA);
}

// ------------------------------------------------------------
// MAIN PAGE
// ------------------------------------------------------------

class ProduceDetailsPage extends StatefulWidget {
  const ProduceDetailsPage({super.key});

  @override
  State<ProduceDetailsPage> createState() => _ProduceDetailsPageState();
}

class _ProduceDetailsPageState extends State<ProduceDetailsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildTopBar(),
                ),

                SliverToBoxAdapter(
                  child: _buildHeroImage(),
                ),

                SliverToBoxAdapter(
                  child: _buildProductHeader(),
                ),

                SliverToBoxAdapter(
                  child: _buildInfoCards(),
                ),

                SliverToBoxAdapter(
                  child: _buildFarmerSection(),
                ),

                SliverToBoxAdapter(
                  child: _buildPricePrediction(),
                ),

                SliverToBoxAdapter(
                  child: _buildMarketPrice(),
                ),

                SliverToBoxAdapter(
                  child: _buildPriceHistory(),
                ),

                SliverToBoxAdapter(
                  child: _buildBottomButtons(),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // TOP BAR
  // ------------------------------------------------------------

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          _iconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {},
          ),
          const Spacer(),
          _iconButton(
            icon: Icons.favorite_border_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 10),
          _iconButton(
            icon: Icons.share_outlined,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: AppColors.green,
            size: 25,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HERO IMAGE
  // ------------------------------------------------------------

  Widget _buildHeroImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1.78,
              child: Image.network(
                'https://images.unsplash.com/photo-1592924357228-91a4daadcfea'
                '?auto=format&fit=crop&w=1200&q=85',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF5DAF55),
                          Color(0xFF197B38),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '🍅',
                        style: TextStyle(fontSize: 90),
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Container(
                    color: const Color(0xFFE8F4EA),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.green,
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              top: 15,
              left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC159447),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Grade A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              right: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '1/5',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
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

  // ------------------------------------------------------------
  // PRODUCT HEADER
  // ------------------------------------------------------------

  Widget _buildProductHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🍅',
                style: TextStyle(fontSize: 35),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Tomato',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.eco_rounded,
                      size: 17,
                      color: AppColors.green,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Fresh Produce',
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppColors.textGrey,
              ),
              const SizedBox(width: 5),
              const Text(
                'Ramesh Patil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.green,
                ),
                child: const Icon(
                  Icons.check,
                  size: 10,
                  color: Colors.white,
                ),
              ),
              const Text(
                '  Verified Farmer',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          const Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.textGrey,
              ),
              SizedBox(width: 5),
              Text(
                'Sangli, Maharashtra',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // INFO CARDS
  // ------------------------------------------------------------

  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: _infoCard(
              icon: Icons.inventory_2_outlined,
              title: 'Quantity',
              value: '500 kg',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _infoCard(
              icon: Icons.verified_outlined,
              title: 'Grade',
              value: 'A',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _infoCard(
              icon: Icons.currency_rupee_rounded,
              title: 'Expected Price',
              value: '₹24/kg',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _infoCard(
              icon: Icons.calendar_month_outlined,
              title: 'Harvested On',
              value: '5 Sep 2025',
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      height: 91,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.green,
            size: 23,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FARMER SECTION
  // ------------------------------------------------------------

  Widget _buildFarmerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(
            color: AppColors.border,
            height: 1,
          ),

          const SizedBox(height: 18),

          const Row(
            children: [
              Icon(
                Icons.agriculture_rounded,
                color: AppColors.green,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Farmer Details',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFDCEFE2),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '👨‍🌾',
                    style: TextStyle(fontSize: 42),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Ramesh Patil',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.verified,
                          color: AppColors.green,
                          size: 18,
                        ),
                      ],
                    ),

                    SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.textGrey,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Sangli, Maharashtra',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF3AE16),
                          size: 19,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          '(32 reviews)',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.person_outline,
                  size: 18,
                ),
                label: const Text(
                  'View Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: const BorderSide(
                    color: Color(0xFFA6D5B9),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // AI PRICE PREDICTION
  // ------------------------------------------------------------

  Widget _buildPricePrediction() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFE9F8EE),
              Color(0xFFF5FCF7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD3EDDB),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD0F0D9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    color: AppColors.green,
                  ),
                ),

                const SizedBox(width: 10),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Price Prediction',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Based on historical data & market trends',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 17),

            Row(
              children: [
                Expanded(
                  child: _pricePredictionItem(
                    title: 'Current Price',
                    price: '₹24/kg',
                    suffix: '↗',
                  ),
                ),

                Container(
                  width: 1,
                  height: 65,
                  color: AppColors.border,
                ),

                Expanded(
                  child: _pricePredictionItem(
                    title: 'Predicted Price (7 days)',
                    price: '₹28/kg',
                    suffix: '▲ +16%',
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F8E9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 18,
                              color: AppColors.green,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'AI Suggestion',
                              style: TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'WAIT',
                              style: TextStyle(
                                color: AppColors.darkGreen,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              '⌛',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Price is likely to increase in the next 7 days.',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 9,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pricePredictionItem({
    required String title,
    required String price,
    required String suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            suffix,
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MARKET PRICE
  // ------------------------------------------------------------

  Widget _buildMarketPrice() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: AppColors.green,
                size: 24,
              ),
              const SizedBox(width: 7),
              const Text(
                'Market Price',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                '(Today)',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View Full Report →',
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: _marketNumber(
                          'Minimum',
                          '₹20/kg',
                        ),
                      ),
                      _verticalDivider(),
                      Expanded(
                        child: _marketNumber(
                          'Maximum',
                          '₹28/kg',
                        ),
                      ),
                      _verticalDivider(),
                      Expanded(
                        child: _marketNumber(
                          'Modal Price',
                          '₹25/kg',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Market Wise Price',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      _marketLocation('Pune', '₹25'),
                      _marketLocation('Sangli', '₹23'),
                      _marketLocation('Kolhapur', '₹26'),
                      _marketLocation('Nashik', '₹24'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _marketNumber(String title, String price) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          price,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 45,
      color: AppColors.border,
    );
  }

  Widget _marketLocation(String city, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 13,
            color: AppColors.textGrey,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              city,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 10,
              ),
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PRICE HISTORY
  // ------------------------------------------------------------

  Widget _buildPriceHistory() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: AppColors.green,
                size: 23,
              ),
              const SizedBox(width: 7),
              const Text(
                'Price History',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              _historyTab('7 Days', true),
              _historyTab('30 Days', false),
              _historyTab('90 Days', false),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            height: 190,
            padding: const EdgeInsets.fromLTRB(15, 10, 12, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: const PriceChart(),
          ),
        ],
      ),
    );
  }

  Widget _historyTab(String title, bool selected) {
    return Container(
      margin: const EdgeInsets.only(left: 5),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: selected ? AppColors.green : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.textGrey,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM BUTTONS
  // ------------------------------------------------------------

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 58,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showMessage(
                    'Opening farmer chat...',
                  );
                },
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 21,
                ),
                label: const Text(
                  'Contact Farmer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: const BorderSide(
                    color: AppColors.green,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: SizedBox(
              height: 58,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showOfferDialog();
                },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 22,
                ),
                label: const Text(
                  'Make Offer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  void _showOfferDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Make an Offer',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: controller,
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                if (controller.text.trim().isNotEmpty) {
                  _showMessage(
                    'Offer ₹${controller.text}/kg sent successfully.',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send Offer'),
            ),
          ],
        );
      },
    );
  }
}

// ------------------------------------------------------------
// ANIMATED PRICE CHART
// ------------------------------------------------------------

class PriceChart extends StatefulWidget {
  const PriceChart({super.key});

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _chartController;

  @override
  void initState() {
    super.initState();

    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _chartController.forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _chartController,
      builder: (context, child) {
        return CustomPaint(
          painter: PriceChartPainter(
            progress: Curves.easeOutCubic.transform(
              _chartController.value,
            ),
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class PriceChartPainter extends CustomPainter {
  final double progress;

  PriceChartPainter({
    required this.progress,
  });

  final List<double> prices = [
    20,
    22,
    23,
    24.5,
    25.5,
    26.2,
    28,
  ];

  final List<String> dates = [
    '1 Sep',
    '2 Sep',
    '3 Sep',
    '4 Sep',
    '5 Sep',
    '6 Sep',
    '7 Sep',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const leftSpace = 38.0;
    const rightSpace = 10.0;
    const topSpace = 10.0;
    const bottomSpace = 32.0;

    final chartWidth = size.width - leftSpace - rightSpace;
    final chartHeight = size.height - topSpace - bottomSpace;

    final maxPrice = 30.0;
    final minPrice = 18.0;

    final gridPaint = Paint()
      ..color = const Color(0xFFE8EFEA)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = AppColors.green
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pointPaint = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.fill;

    // Horizontal grid lines
    final gridPrices = [18, 22, 26, 30];

    for (final price in gridPrices) {
      final y = topSpace +
          chartHeight -
          ((price - minPrice) / (maxPrice - minPrice)) *
              chartHeight;

      canvas.drawLine(
        Offset(leftSpace, y),
        Offset(size.width - rightSpace, y),
        gridPaint,
      );

      _drawText(
        canvas,
        '₹ $price',
        Offset(0, y - 7),
        fontSize: 10,
        color: AppColors.textGrey,
      );
    }

    final points = <Offset>[];

    for (int i = 0; i < prices.length; i++) {
      final x = leftSpace +
          (i / (prices.length - 1)) * chartWidth;

      final y = topSpace +
          chartHeight -
          ((prices[i] - minPrice) / (maxPrice - minPrice)) *
              chartHeight;

      points.add(Offset(x, y));
    }

    final visibleCount =
        math.max(2, (points.length * progress).ceil());

    final visiblePoints =
        points.take(visibleCount).toList();

    if (visiblePoints.length >= 2) {
      final path = Path();

      path.moveTo(
        visiblePoints.first.dx,
        visiblePoints.first.dy,
      );

      for (int i = 1; i < visiblePoints.length; i++) {
        final previous = visiblePoints[i - 1];
        final current = visiblePoints[i];

        final controlPoint1 = Offset(
          previous.dx + (current.dx - previous.dx) / 2,
          previous.dy,
        );

        final controlPoint2 = Offset(
          previous.dx + (current.dx - previous.dx) / 2,
          current.dy,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          current.dx,
          current.dy,
        );
      }

      canvas.drawPath(path, linePaint);

      // Filled area
      final fillPath = Path.from(path);

      fillPath.lineTo(
        visiblePoints.last.dx,
        topSpace + chartHeight,
      );

      fillPath.lineTo(
        visiblePoints.first.dx,
        topSpace + chartHeight,
      );

      fillPath.close();

      final fillPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x5520A65A),
            Color(0x0820A65A),
          ],
        ).createShader(
          Rect.fromLTWH(
            leftSpace,
            topSpace,
            chartWidth,
            chartHeight,
          ),
        );

      canvas.drawPath(fillPath, fillPaint);
    }

    // Points
    for (int i = 0; i < visiblePoints.length; i++) {
      final point = visiblePoints[i];

      canvas.drawCircle(
        point,
        4,
        Paint()..color = Colors.white,
      );

      canvas.drawCircle(
        point,
        2.8,
        pointPaint,
      );
    }

    // Dates
    for (int i = 0; i < dates.length; i++) {
      final x = leftSpace +
          (i / (dates.length - 1)) * chartWidth;

      _drawText(
        canvas,
        dates[i],
        Offset(x - 12, size.height - 22),
        fontSize: 9,
        color: AppColors.textGrey,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    double fontSize = 10,
    Color color = Colors.black,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      offset,
    );
  }

  @override
  bool shouldRepaint(covariant PriceChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}