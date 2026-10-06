import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xFF087F45);
  static const Color darkGreen = Color(0xFF075C3A);
  static const Color softGreen = Color(0xFFEAF8EF);
  static const Color lightGreen = Color(0xFFF3FBF6);
  static const Color textDark = Color(0xFF164C3B);
  static const Color textGrey = Color(0xFF71877E);

  static const Color red = Color(0xFFE9234B);
  static const Color redLight = Color(0xFFFFF5F7);

  // ============================================================
  // VARIABLES
  // ============================================================

  final ImagePicker _picker = ImagePicker();

  File? selectedImage;

  bool analyzing = false;

  int selectedNav = 1;

  late AnimationController pageAnimation;
  late AnimationController pulseAnimation;

  // ============================================================
  // IMAGE URLs
  // ============================================================

  final String farmImage =
      'https://images.unsplash.com/photo-1500382017468-9049fed747ef'
      '?auto=format&fit=crop&w=1200&q=85';

  final String leafImage =
      'https://images.unsplash.com/photo-1592841200221-a6898f307baa'
      '?auto=format&fit=crop&w=900&q=90';

  final String diseaseImage =
      'https://images.unsplash.com/photo-1592924357228-91a4daadcfea'
      '?auto=format&fit=crop&w=900&q=90';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    pageAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    pulseAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.96,
      upperBound: 1.04,
    )..repeat(reverse: true);

    pageAnimation.forward();
  }

  @override
  void dispose() {
    pageAnimation.dispose();
    pulseAnimation.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK CAMERA
  // ============================================================

  Future<void> openCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1600,
      );

      if (photo == null) return;

      setState(() {
        selectedImage = File(photo.path);
        analyzing = true;
      });

      await Future.delayed(
        const Duration(milliseconds: 1500),
      );

      if (!mounted) return;

      setState(() {
        analyzing = false;
      });

      showSnackBar('Crop analysis completed');
    } catch (_) {
      showSnackBar('Camera could not be opened');
    }
  }

  // ============================================================
  // PICK GALLERY
  // ============================================================

  Future<void> openGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1600,
      );

      if (photo == null) return;

      setState(() {
        selectedImage = File(photo.path);
        analyzing = true;
      });

      await Future.delayed(
        const Duration(milliseconds: 1500),
      );

      if (!mounted) return;

      setState(() {
        analyzing = false;
      });

      showSnackBar('Crop analysis completed');
    } catch (_) {
      showSnackBar('Gallery could not be opened');
    }
  }

  // ============================================================
  // REMOVE PHOTO
  // ============================================================

  void removePhoto() {
    setState(() {
      selectedImage = null;
    });
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void showSnackBar(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: darkGreen,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // ANIMATION
  // ============================================================

  Widget reveal({
    required double begin,
    required double end,
    required Widget child,
  }) {
    final animation = CurvedAnimation(
      parent: pageAnimation,
      curve: Interval(
        begin,
        end,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(
              0,
              35 * (1 - animation.value),
            ),
            child: child,
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: buildHeader(),
                  ),

                  SliverToBoxAdapter(
                    child: reveal(
                      begin: 0.00,
                      end: 0.18,
                      child: buildAiInfo(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: reveal(
                      begin: 0.12,
                      end: 0.35,
                      child: buildScannerCard(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: reveal(
                      begin: 0.25,
                      end: 0.48,
                      child: buildDiseaseCard(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: reveal(
                      begin: 0.38,
                      end: 0.62,
                      child: buildTreatmentCard(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: reveal(
                      begin: 0.52,
                      end: 0.75,
                      child: buildTipsCard(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: reveal(
                      begin: 0.65,
                      end: 0.90,
                      child: buildBottomBanner(),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 15),
                  ),
                ],
              ),
            ),

            buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget buildHeader() {
    return SizedBox(
      height: 190,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              farmImage,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFE8F8EE),
                        Color(0xFFCFECDD),
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
                    Colors.white.withValues(alpha: .96),
                    Colors.white.withValues(alpha: .60),
                    const Color(0xFFF8FCFA),
                  ],
                ),
              ),
            ),
          ),

          // BACK
          Positioned(
            left: 18,
            top: 18,
            child: circleButton(
              Icons.arrow_back_ios_new_rounded,
              () => Navigator.maybePop(context),
            ),
          ),

          // LOGO
          Positioned(
            left: 88,
            top: 22,
            right: 55,
            child: Row(
              children: [
                Container(
                  width: 53,
                  height: 53,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),

                const SizedBox(width: 9),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AgroConnect',
                        style: TextStyle(
                          color: primary,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'AI Disease Detection',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Healthy Crops • Better Yield • Higher Profit',
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // NOTIFICATION
          Positioned(
            right: 15,
            top: 18,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                circleButton(
                  Icons.notifications_none_rounded,
                  () {
                    showSnackBar('You have 3 notifications');
                  },
                ),

                Positioned(
                  right: -3,
                  top: -5,
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget circleButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: const Color(0xFFEAF8EF),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 49,
          height: 49,
          child: Icon(
            icon,
            color: primary,
            size: 25,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AI INFORMATION
  // ============================================================

  Widget buildAiInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(23, 0, 23, 12),
      child: appCard(
        color: const Color(0xFFEFFAF3),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (_, child) {
                  return Transform.scale(
                    scale: pulseAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD8F1E1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.memory_rounded,
                    color: primary,
                    size: 29,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Powered Crop Health Analysis',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Upload a photo of your crop leaf, and our AI '
                      'will detect diseases and suggest the best treatment.',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SCANNER CARD
  // ============================================================

  Widget buildScannerCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(23, 0, 23, 13),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: lightGreen,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFAEDDC5),
            width: 1.3,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: primary,
                    size: 33,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Crop Photo',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Take a clear photo of the affected leaf '
                        'or choose from gallery.',
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 10.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                buildPreview(),
              ],
            ),

            const SizedBox(height: 13),

            Row(
              children: [
                Expanded(
                  child: primaryButton(
                    icon: Icons.camera_alt_rounded,
                    text: 'Take Photo',
                    onTap: openCamera,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: outlineButton(
                    icon: Icons.photo_library_outlined,
                    text: 'Choose from Gallery',
                    onTap: openGallery,
                  ),
                ),
              ],
            ),

            if (analyzing) ...[
              const SizedBox(height: 11),

              const LinearProgressIndicator(
                minHeight: 4,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                color: primary,
                backgroundColor: Color(0xFFDCEFE3),
              ),

              const SizedBox(height: 5),

              const Text(
                'AI is analyzing your crop...',
                style: TextStyle(
                  color: primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PREVIEW
  // ============================================================

  Widget buildPreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 105,
            height: 105,
            child: selectedImage != null
                ? Image.file(
                    selectedImage!,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    leafImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return Container(
                        color: const Color(0xFFDFF1E5),
                        alignment: Alignment.center,
                        child: const Text(
                          '🌿',
                          style: TextStyle(fontSize: 42),
                        ),
                      );
                    },
                  ),
          ),
        ),

        if (selectedImage != null)
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: removePhoto,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: darkGreen,
                  size: 18,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // DISEASE CARD
  // ============================================================

  Widget buildDiseaseCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(23, 0, 23, 13),
      child: appCard(
        color: redLight,
        borderColor: const Color(0xFFF1D7DD),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_florist_rounded,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),

                        const SizedBox(width: 9),

                        const Expanded(
                          child: Text(
                            'Disease Detected',
                            style: TextStyle(
                              color: red,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Early Blight',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text(
                      '(Alternaria solani)',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Dark, circular spots with yellow halos on leaves, '
                      'which can later turn into larger lesions and affect '
                      'the entire plant.',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 10.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4EA),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        'Confidence: 92%',
                        style: TextStyle(
                          color: red,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(height: 9),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 125,
                        child: Image.network(
                          diseaseImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return Container(
                              color: const Color(0xFFDFF1E5),
                              alignment: Alignment.center,
                              child: const Text(
                                '🍃',
                                style: TextStyle(fontSize: 50),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4EA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Affected Area Highlighted',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: red,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TREATMENT
  // ============================================================

  Widget buildTreatmentCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(23, 0, 23, 13),
      child: appCard(
        color: const Color(0xFFF0FAF4),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDDF4E5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: primary,
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 9),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommended Treatment',
                          style: TextStyle(
                            color: textDark,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Follow these steps to control the disease '
                          'and protect your crop.',
                          style: TextStyle(
                            color: textGrey,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 11),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 90,
                      height: 122,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF7EE),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_drink_outlined,
                            color: primary,
                            size: 51,
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Topsin M\n70 WP',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: darkGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tata Rallis Topsin M 70 WP',
                            style: TextStyle(
                              color: textDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: softGreen,
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Fungicide',
                              style: TextStyle(
                                color: primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          const SizedBox(height: 9),

                          treatmentRow(
                            Icons.water_drop_outlined,
                            'Dosage: 2 gm per liter of water',
                          ),

                          const SizedBox(height: 7),

                          treatmentRow(
                            Icons.calendar_month_outlined,
                            'Apply: Once in 7 days',
                          ),

                          const SizedBox(height: 7),

                          treatmentRow(
                            Icons.eco_outlined,
                            'Suitable for: Tomato, Potato, Brinjal',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 5),

                    SizedBox(
                      width: 90,
                      child: primaryButton(
                        icon: Icons.shopping_cart_outlined,
                        text: 'Buy Now',
                        onTap: () {
                          showSnackBar(
                            'Opening treatment product',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget treatmentRow(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: primary,
          size: 16,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: textGrey,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TIPS
  // ============================================================

  Widget buildTipsCard() {
    const tips = [
      'Remove infected leaves and destroy them.',
      'Ensure proper drainage in the field.',
      'Avoid overhead irrigation.',
      'Use disease resistant varieties.',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 0, 36, 13),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F7EC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD4F0DD),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: primary,
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 7),

                      const Text(
                        'Additional Tips',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  for (final tip in tips)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: primary,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                color: Color(0xFF48796A),
                                fontSize: 8.7,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Expanded(
              flex: 3,
              child: Column(
                children: [
                  Text(
                    '🌱',
                    style: TextStyle(fontSize: 50),
                  ),
                  Text(
                    'Healthy Plants\nHappy Farmers',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
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

  // ============================================================
  // BOTTOM BANNER
  // ============================================================

  Widget buildBottomBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(23, 0, 23, 2),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1FBF5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFD3EDE0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFDDF3E5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: primary,
                size: 23,
              ),
            ),

            const SizedBox(width: 8),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Early detection saves your crop!',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Upload regularly for better results.',
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              width: 145,
              child: primaryButton(
                icon: Icons.camera_alt_outlined,
                text: 'Scan Another Photo',
                onTap: openGallery,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COMMON CARD
  // ============================================================

  Widget appCard({
    required Widget child,
    required Color color,
    Color borderColor = const Color(0xFFD3EDE0),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // PRIMARY BUTTON
  // ============================================================

  Widget primaryButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 43,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 17,
        ),
        label: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OUTLINE BUTTON
  // ============================================================

  Widget outlineButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 43,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 17,
        ),
        label: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(
            color: Color(0xFF83CBA2),
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget buildBottomNavigation() {
    const labels = [
      'Home',
      'AI Doctor',
      'Market',
      'Orders',
      'Profile',
    ];

    const icons = [
      Icons.home_rounded,
      Icons.spa_rounded,
      Icons.bar_chart_rounded,
      Icons.assignment_outlined,
      Icons.person_outline_rounded,
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
          height: 70,
          child: Row(
            children: List.generate(
              labels.length,
              (index) {
                final bool active =
                    selectedNav == index;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedNav = index;
                      });

                      if (index != 1) {
                        showSnackBar(
                          '${labels[index]} selected',
                        );
                      }
                    },
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: active ? 1.08 : 1.0,
                          duration:
                              const Duration(milliseconds: 220),
                          curve: Curves.easeOutBack,
                          child: Icon(
                            icons[index],
                            size: 26,
                            color: active
                                ? primary
                                : const Color(0xFF8B9993),
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          labels[index],
                          style: TextStyle(
                            color: active
                                ? primary
                                : const Color(0xFF8B9993),
                            fontSize: 9.5,
                            fontWeight: active
                                ? FontWeight.w900
                                : FontWeight.w600,
                          ),
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
}