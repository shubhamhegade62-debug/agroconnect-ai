
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// -----------------------------------------------------------------------
/// CROP SCAN SCREEN
///
/// Web-compatible version.
/// - Camera / Gallery image selection
/// - Image preview
/// - Animated scanning line
/// - Demo AI result
///
/// NOTE:
/// `tflite_flutter` is intentionally NOT used here because the app is
/// currently being run on Chrome/Web.
///
/// When you later want REAL TFLite inference, it should be added through
/// a platform-specific implementation (Android/iOS), or replaced with
/// a web-compatible ML solution.
/// -----------------------------------------------------------------------

class CropScanScreen extends StatefulWidget {
  const CropScanScreen({super.key});

  @override
  State<CropScanScreen> createState() => _CropScanScreenState();
}

class _CropScanScreenState extends State<CropScanScreen>
    with SingleTickerProviderStateMixin {
  static const int _inputSize = 224;
  static const int _numChannels = 3;

  final ImagePicker _picker = ImagePicker();

  Uint8List? _imageBytes;

  bool _isRunningInference = false;

  String? _resultLabel;
  double? _resultConfidence;

  late final AnimationController _scanAnimController;

  final List<String> _labels = [
    'Healthy',
    'Early Blight',
    'Late Blight',
    'Leaf Rust',
    'Bacterial Spot',
    'Powdery Mildew',
  ];

  @override
  void initState() {
    super.initState();

    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // PICK IMAGE
  // -----------------------------------------------------------------------

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1400,
        maxHeight: 1400,
      );

      if (picked == null) return;

      final bytes = await picked.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _resultLabel = null;
        _resultConfidence = null;
      });

      await _runInference(bytes);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _resultLabel = 'Unable to read image';
        _resultConfidence = null;
      });

      _showMessage('Image error: $e');
    }
  }

  // -----------------------------------------------------------------------
  // DEMO AI / IMAGE PROCESSING
  // -----------------------------------------------------------------------

  Future<void> _runInference(Uint8List bytes) async {
    if (!mounted) return;

    setState(() {
      _isRunningInference = true;
      _resultLabel = null;
      _resultConfidence = null;
    });

    try {
      // Decode image so that the image is actually processed.
      final decoded = img.decodeImage(bytes);

      if (decoded == null) {
        throw Exception('Could not decode image');
      }

      // Resize to the same dimensions normally expected by the model.
      final resized = img.copyResize(
        decoded,
        width: _inputSize,
        height: _inputSize,
      );

      // Create normalized RGB data.
      //
      // This prepares the image in the same general format used by many
      // TensorFlow Lite image classifiers.
      final input = _imageToFloat32(
        resized,
        _inputSize,
        _numChannels,
      );

      // Prevent unused-variable warning and demonstrate that preprocessing
      // completed successfully.
      debugPrint('Preprocessed ${input.length} values');

      // DEMO AI RESULT
      //
      // This delay simulates model inference while keeping the app fully
      // compatible with Chrome/Web.
      await Future.delayed(const Duration(milliseconds: 1800));

      if (!mounted) return;

      // Simple demo result.
      //
      // Replace this section later with your real web-compatible ML model.
      setState(() {
        _resultLabel = 'Early Blight';
        _resultConfidence = 0.87;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _resultLabel = 'Error analyzing image';
        _resultConfidence = null;
      });

      _showMessage('Analysis error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRunningInference = false;
        });
      }
    }
  }

  // -----------------------------------------------------------------------
  // IMAGE -> FLOAT32
  // -----------------------------------------------------------------------

  Float32List _imageToFloat32(
    img.Image image,
    int inputSize,
    int channels,
  ) {
    final buffer = Float32List(
      inputSize * inputSize * channels,
    );

    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);

        buffer[pixelIndex++] = pixel.r / 255.0;
        buffer[pixelIndex++] = pixel.g / 255.0;
        buffer[pixelIndex++] = pixel.b / 255.0;
      }
    }

    return buffer;
  }

  // -----------------------------------------------------------------------
  // MESSAGE
  // -----------------------------------------------------------------------

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // -----------------------------------------------------------------------
  // RESULT CARD
  // -----------------------------------------------------------------------

  Widget _resultCard() {
    if (_resultLabel == null) {
      return const SizedBox.shrink();
    }

    final bool isHealthy = _resultLabel == 'Healthy';

    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 3,
        color: const Color(0xFFEFF7EF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isHealthy
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isHealthy ? Icons.check_circle : Icons.biotech,
                  color: isHealthy
                      ? Colors.green.shade700
                      : const Color(0xFF1F5B3A),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Detection Result',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _resultLabel!,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F5B3A),
                      ),
                    ),
                    if (_resultConfidence != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Confidence: ${(_resultConfidence! * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // SCANNER AREA
  // -----------------------------------------------------------------------

  Widget _scannerArea() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.green.shade50,
        border: Border.all(
          color: const Color(0xFF1F5B3A),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // IMAGE
          if (_imageBytes != null)
            Image.memory(
              _imageBytes!,
              fit: BoxFit.cover,
            )
          else
            Container(
              color: const Color(0xFFF0F8F2),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.eco,
                      size: 90,
                      color: Color(0xFFB7D9BC),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Select a crop leaf photo',
                      style: TextStyle(
                        color: Color(0xFF557A61),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // DARK OVERLAY WHILE SCANNING
          if (_isRunningInference)
            Container(
              color: Colors.black.withValues(alpha: 0.10),
            ),

          // SCANNING LINE
          if (_isRunningInference)
            AnimatedBuilder(
              animation: _scanAnimController,
              builder: (context, child) {
                return Align(
                  alignment: Alignment(
                    0,
                    -1 + (2 * _scanAnimController.value),
                  ),
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent.withValues(alpha: 0.7),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // CORNER FRAME
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerFramePainter(),
            ),
          ),

          // ANALYZING LABEL
          if (_isRunningInference)
            const Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 9,
                    ),
                    child: Text(
                      'Analyzing crop...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // BUILD
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBF9),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Crop Scanner',
          style: TextStyle(
            color: Color(0xFF1F5B3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF1F5B3A),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              // TITLE
              const Text(
                'AI Crop Health Scan',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F5B3A),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Point your camera at a leaf to detect disease',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 16),

              // SCANNER
              Expanded(
                child: _scannerArea(),
              ),

              const SizedBox(height: 14),

              // RESULT
              _resultCard(),

              if (_resultLabel != null)
                const SizedBox(height: 10),

              // BUTTONS
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isRunningInference
                          ? null
                          : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F5B3A),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade400,
                        disabledForegroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 17,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isRunningInference
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1F5B3A),
                        side: const BorderSide(
                          color: Color(0xFF1F5B3A),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 17,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------------
// SCANNER CORNER PAINTER
// -------------------------------------------------------------------------

class ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 28;

    // Top-left
    canvas.drawLine(
      const Offset(15, 15),
      const Offset(15 + cornerLength, 15),
      paint,
    );

    canvas.drawLine(
      const Offset(15, 15),
      const Offset(15, 15 + cornerLength),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - 15, 15),
      Offset(size.width - 15 - cornerLength, 15),
      paint,
    );

    canvas.drawLine(
      Offset(size.width - 15, 15),
      Offset(size.width - 15, 15 + cornerLength),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(15, size.height - 15),
      Offset(15 + cornerLength, size.height - 15),
      paint,
    );

    canvas.drawLine(
      Offset(15, size.height - 15),
      Offset(15, size.height - 15 - cornerLength),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - 15, size.height - 15),
      Offset(size.width - 15 - cornerLength, size.height - 15),
      paint,
    );

    canvas.drawLine(
      Offset(size.width - 15, size.height - 15),
      Offset(size.width - 15, size.height - 15 - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
