// TODO Implement this library.
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// -----------------------------------------------------------------------
/// CROP SCAN SCREEN — this is the real ML entry point of the app.
///
/// Flow:
///   1. Farmer takes/picks a photo of a crop leaf.
///   2. Image is resized + normalized to match the model's input tensor.
///   3. A TensorFlow Lite interpreter runs inference on-device (offline,
///      fast, works in low-connectivity rural areas).
///   4. Output probabilities are mapped to human-readable labels
///      (e.g. "Tomato - Early Blight", "Healthy", "Wheat - Rust").
///
/// TO PLUG IN YOUR OWN TRAINED MODEL:
///   - Train/export a classifier (e.g. MobileNetV2 transfer-learned on
///     PlantVillage or your own labeled dataset) to a `.tflite` file.
///   - Drop it at: assets/model/crop_model.tflite
///   - Drop your label list (one label per line) at: assets/model/labels.txt
///   - Add both to pubspec.yaml under `flutter: assets:`
///   - Update _inputSize / _numChannels below to match your model's
///     expected input shape (commonly 224x224x3).
/// -----------------------------------------------------------------------
class CropScanScreen extends StatefulWidget {
  const CropScanScreen({super.key});

  @override
  State<CropScanScreen> createState() => _CropScanScreenState();
}

class _CropScanScreenState extends State<CropScanScreen>
    with SingleTickerProviderStateMixin {
  static const int _inputSize = 224; // model's expected width/height
  static const int _numChannels = 3;

  File? _imageFile;
  bool _isLoadingModel = false;
  bool _isRunningInference = false;
  String? _resultLabel;
  double? _resultConfidence;

  Interpreter? _interpreter;
  List<String> _labels = [];

  late final AnimationController _scanAnimController;

  @override
  void initState() {
    super.initState();
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadModel();
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    _interpreter?.close();
    super.dispose();
  }

  /// Loads the TFLite model + labels from assets.
  /// Wrapped in try/catch so the UI degrades gracefully (mock mode)
  /// if no model has been added yet — handy while building the UI first.
  Future<void> _loadModel() async {
    setState(() => _isLoadingModel = true);
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/crop_model.tflite');
      // Labels file: one class name per line, in the same order the
      // model was trained on.
      // final raw = await rootBundle.loadString('assets/model/labels.txt');
      // _labels = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
      _labels = [
        'Healthy',
        'Early Blight',
        'Late Blight',
        'Leaf Rust',
        'Bacterial Spot',
        'Powdery Mildew',
      ];
    } catch (e) {
      debugPrint('Model not found yet, running in demo mode: $e');
      _interpreter = null;
    } finally {
      if (mounted) setState(() => _isLoadingModel = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _resultLabel = null;
      _resultConfidence = null;
    });

    await _runInference(_imageFile!);
  }

  /// Preprocesses the image and runs it through the TFLite interpreter.
  Future<void> _runInference(File file) async {
    setState(() => _isRunningInference = true);

    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw Exception('Could not decode image');

      final resized = img.copyResize(
        decoded,
        width: _inputSize,
        height: _inputSize,
      );

      // Convert to normalized Float32 [1, H, W, 3] tensor, values 0-1.
      final input = _imageToByteListFloat32(resized, _inputSize, _numChannels);

      if (_interpreter != null) {
        final output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);
        _interpreter!.run(input, output);

        final scores = List<double>.from(output[0]);
        final maxScore = scores.reduce((a, b) => a > b ? a : b);
        final maxIndex = scores.indexOf(maxScore);

        setState(() {
          _resultLabel = _labels[maxIndex];
          _resultConfidence = maxScore;
        });
      } else {
        // DEMO MODE: no .tflite model bundled yet — simulate a result
        // so the UI/UX can be reviewed end-to-end before the model lands.
        await Future.delayed(const Duration(milliseconds: 900));
        setState(() {
          _resultLabel = 'Early Blight (demo result — add crop_model.tflite)';
          _resultConfidence = 0.87;
        });
      }
    } catch (e) {
      setState(() {
        _resultLabel = 'Error running detection: $e';
        _resultConfidence = null;
      });
    } finally {
      if (mounted) setState(() => _isRunningInference = false);
    }
  }

  /// Converts a decoded image into the flat Float32 buffer shape
  /// [1, inputSize, inputSize, channels] most TFLite classifiers expect.
  Float32List _imageToByteListFloat32(img.Image image, int inputSize, int channels) {
    final buffer = Float32List(1 * inputSize * inputSize * channels);
    var pixelIndex = 0;
    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        buffer[pixelIndex++] = pixel.r / 255.0;
        buffer[pixelIndex++] = pixel.g / 255.0;
        buffer[pixelIndex++] = pixel.b / 255.0;
      }
    }
    return buffer;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'AI Crop Health Scan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F5B3A),
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Point your camera at a leaf to detect disease',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),

          // ---------- IMAGE PREVIEW / SCANNER FRAME ----------
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.green.shade50,
                border: Border.all(color: const Color(0xFF1F5B3A), width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_imageFile != null)
                    Image.file(_imageFile!, fit: BoxFit.cover)
                  else
                    const Center(
                      child: Icon(Icons.eco, size: 90, color: Color(0xFFB7D9BC)),
                    ),

                  // animated scanning line overlay while inference runs
                  if (_isRunningInference)
                    AnimatedBuilder(
                      animation: _scanAnimController,
                      builder: (context, child) {
                        return Align(
                          alignment: Alignment(0, -1 + 2 * _scanAnimController.value),
                          child: Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            color: Colors.greenAccent.withValues(alpha: 0.9),
                          ),
                        );
                      },
                    ),

                  if (_isRunningInference)
                    const Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          'Analyzing…',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            backgroundColor: Colors.black45,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ---------- RESULT CARD ----------
          if (_resultLabel != null)
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 400),
              child: Card(
                color: const Color(0xFFEFF7EF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: const Icon(Icons.biotech, color: Color(0xFF1F5B3A)),
                  title: Text(_resultLabel!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: _resultConfidence != null
                      ? Text('Confidence: ${(_resultConfidence! * 100).toStringAsFixed(1)}%')
                      : null,
                ),
              ),
            ),

          const SizedBox(height: 12),

          // ---------- CAPTURE BUTTONS ----------
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoadingModel ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoadingModel ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1F5B3A),
                    side: const BorderSide(color: Color(0xFF1F5B3A)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}