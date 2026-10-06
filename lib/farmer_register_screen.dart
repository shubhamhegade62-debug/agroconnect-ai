import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_colors.dart';
import 'shared_widgets.dart';

class FarmerRegisterScreen extends StatefulWidget {
  const FarmerRegisterScreen({super.key});

  @override
  State<FarmerRegisterScreen> createState() => _FarmerRegisterScreenState();
}

class _FarmerRegisterScreenState extends State<FarmerRegisterScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _nameFade;
  late final Animation<Offset> _nameSlide;
  late final Animation<double> _mobileFade;
  late final Animation<Offset> _mobileSlide;
  late final Animation<double> _passwordFade;
  late final Animation<Offset> _passwordSlide;
  late final Animation<double> _satbaraFade;
  late final Animation<Offset> _satbaraSlide;
  late final Animation<double> _docFade;
  late final Animation<Offset> _docSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  late final AnimationController _leafController;
  late final AnimationController _eyeController;

  bool _obscurePassword = true;
  bool _isRegistering = false;

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _satbaraController = TextEditingController();

  File? _documentFile;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoFade = _buildFade(0.0, 0.30);
    _logoSlide = _buildSlide(0.0, 0.30);

    _headerFade = _buildFade(0.08, 0.40);
    _headerSlide = _buildSlide(0.08, 0.40);

    _nameFade = _buildFade(0.18, 0.50);
    _nameSlide = _buildSlide(0.18, 0.50);

    _mobileFade = _buildFade(0.28, 0.60);
    _mobileSlide = _buildSlide(0.28, 0.60);

    _passwordFade = _buildFade(0.38, 0.70);
    _passwordSlide = _buildSlide(0.38, 0.70);

    _satbaraFade = _buildFade(0.48, 0.80);
    _satbaraSlide = _buildSlide(0.48, 0.80);

    _docFade = _buildFade(0.58, 0.88);
    _docSlide = _buildSlide(0.58, 0.88);

    _buttonFade = _buildFade(0.68, 1.0);
    _buttonSlide = _buildSlide(0.68, 1.0);

    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _eyeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _entranceController.forward();
  }

  Animation<double> _buildFade(double start, double end) {
    return CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _buildSlide(double start, double end) {
    return Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _leafController.dispose();
    _eyeController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _satbaraController.dispose();
    super.dispose();
  }

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
      if (_obscurePassword) {
        _eyeController.reverse();
      } else {
        _eyeController.forward();
      }
    });
  }

  Future<void> _pickDocument() async {
    // Bottom sheet: choose Camera or Gallery for the 7/12 / ID document photo
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.fieldBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined,
                    color: AppColors.primaryGreen),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primaryGreen),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() => _documentFile = File(picked.path));
    }
  }

  Future<void> _handleRegisterTap() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (_documentFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your 7/12 or ID document'),
          backgroundColor: AppColors.darkGreen,
        ),
      );
      return;
    }

    setState(() => _isRegistering = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _isRegistering = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration successful! You can now log in.'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FarmlandFooter(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FadeTransition(
                            opacity: _nameFade,
                            child: SlideTransition(
                              position: _nameSlide,
                              child: AnimatedTextField(
                                controller: _nameController,
                                label: 'Full Name',
                                hint: 'Enter your full name',
                                icon: Icons.person_outline,
                                keyboardType: TextInputType.name,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeTransition(
                            opacity: _mobileFade,
                            child: SlideTransition(
                              position: _mobileSlide,
                              child: AnimatedTextField(
                                controller: _mobileController,
                                label: 'Mobile Number',
                                hint: 'Enter your mobile number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeTransition(
                            opacity: _passwordFade,
                            child: SlideTransition(
                              position: _passwordSlide,
                              child: AnimatedTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'Create a password',
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                trailing: AnimatedEyeIcon(
                                  controller: _eyeController,
                                  obscured: _obscurePassword,
                                  onTap: _togglePassword,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeTransition(
                            opacity: _satbaraFade,
                            child: SlideTransition(
                              position: _satbaraSlide,
                              child: AnimatedTextField(
                                controller: _satbaraController,
                                label: '7/12 Extract Number',
                                hint: 'Enter your 7/12 (Satbara) number',
                                icon: Icons.landscape_outlined,
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeTransition(
                            opacity: _docFade,
                            child: SlideTransition(
                              position: _docSlide,
                              child: _buildDocumentUpload(),
                            ),
                          ),
                          const SizedBox(height: 26),
                          FadeTransition(
                            opacity: _buttonFade,
                            child: SlideTransition(
                              position: _buttonSlide,
                              child: PrimaryGradientButton(
                                label: 'Register',
                                icon: Icons.person_add_alt_1,
                                isLoading: _isRegistering,
                                onTap: _handleRegisterTap,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          FadeTransition(
                            opacity: _buttonFade,
                            child: Center(
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(text: 'Already have an account? '),
                                      TextSpan(
                                        text: 'Login',
                                        style: TextStyle(
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 160),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '7/12 or Farmer ID Document',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
        PressableScale(
          onTap: _pickDocument,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _documentFile != null
                    ? AppColors.primaryGreen
                    : AppColors.fieldBorder,
                width: _documentFile != null ? 1.6 : 1,
              ),
            ),
            child: _documentFile == null
                ? Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.upload_file_outlined,
                            color: AppColors.primaryGreen, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Upload document',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Photo of your 7/12 extract or farmer ID',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.camera_alt_outlined,
                          color: AppColors.textGrey),
                    ],
                  )
                : Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _documentFile!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Document uploaded',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _documentFile!.path.split('/').last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _documentFile = null),
                        icon: const Icon(Icons.close,
                            color: AppColors.textGrey, size: 20),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroHeader() {
    return ClipPath(
      clipper: CurveClipper(),
      child: Container(
        height: 300,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDCEFE3), Color(0xFFEFF7EE)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -10,
              right: -10,
              child: AnimatedBuilder(
                animation: _leafController,
                builder: (context, child) {
                  final angle =
                      math.sin(_leafController.value * 2 * math.pi) * 0.06;
                  final dy = math.sin(_leafController.value * 2 * math.pi) * 4;
                  return Transform.translate(
                    offset: Offset(0, dy),
                    child: Transform.rotate(angle: angle, child: child),
                  );
                },
                child: const LeafCluster(size: 80),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 44, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: SlideTransition(
                      position: _logoSlide,
                      child: AnimatedLogo(leafController: _leafController),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Farmer Registration',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Join AgroConnect and sell your\nproduce directly to buyers.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textGrey,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
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
}