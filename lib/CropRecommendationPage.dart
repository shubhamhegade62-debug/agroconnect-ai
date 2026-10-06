import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CropRecommendationPage extends StatefulWidget {
  const CropRecommendationPage({super.key});

  @override
  State<CropRecommendationPage> createState() =>
      _CropRecommendationPageState();
}

class _CropRecommendationPageState
    extends State<CropRecommendationPage> {
  File? selectedImage;

  bool analyzing = false;
  String? recommendation;
  String? errorMessage;

  final ImagePicker picker = ImagePicker();

  // =========================================================
  // API URL
  // =========================================================
  //
  // Flutter Web / Windows:
  // http://127.0.0.1:5000
  //
  // Physical Android Phone:
  // http://10.100.96.4:5000
  //
  // Flask server is running on:
  // http://10.100.96.4:5000
  //
  String get apiUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:5000";
    }

    if (Platform.isAndroid) {
      return "http://10.100.96.4:5000";
    }

    return "http://127.0.0.1:5000";
  }

  // =========================================================
  // Controllers
  // =========================================================

  final TextEditingController nController =
      TextEditingController(text: "90");

  final TextEditingController pController =
      TextEditingController(text: "42");

  final TextEditingController kController =
      TextEditingController(text: "43");

  final TextEditingController temperatureController =
      TextEditingController(text: "20.8");

  final TextEditingController humidityController =
      TextEditingController(text: "82");

  final TextEditingController phController =
      TextEditingController(text: "6.5");

  final TextEditingController rainfallController =
      TextEditingController(text: "202.9");

  @override
  void dispose() {
    nController.dispose();
    pController.dispose();
    kController.dispose();
    temperatureController.dispose();
    humidityController.dispose();
    phController.dispose();
    rainfallController.dispose();

    super.dispose();
  }

  // =========================================================
  // Pick Image
  // =========================================================

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
        recommendation = null;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Unable to select image: $e";
      });
    }
  }

  // =========================================================
  // AI Crop Recommendation
  // =========================================================

  Future<void> analyzeCrop() async {
    setState(() {
      analyzing = true;
      recommendation = null;
      errorMessage = null;
    });

    try {
      // -------------------------------------------------------
      // Read values
      // -------------------------------------------------------

      final double n =
          double.parse(nController.text.trim());

      final double p =
          double.parse(pController.text.trim());

      final double k =
          double.parse(kController.text.trim());

      final double temperature =
          double.parse(temperatureController.text.trim());

      final double humidity =
          double.parse(humidityController.text.trim());

      final double ph =
          double.parse(phController.text.trim());

      final double rainfall =
          double.parse(rainfallController.text.trim());

      // -------------------------------------------------------
      // Request body
      // -------------------------------------------------------

      final Map<String, dynamic> body = {
        "N": n,
        "P": p,
        "K": k,
        "temperature": temperature,
        "humidity": humidity,
        "ph": ph,
        "rainfall": rainfall,
      };

      // -------------------------------------------------------
      // Debug information
      // -------------------------------------------------------

      debugPrint(
        "============================================",
      );

      debugPrint(
        "AI CROP RECOMMENDATION",
      );

      debugPrint(
        "============================================",
      );

      debugPrint(
        "API URL: $apiUrl/predict",
      );

      debugPrint(
        "Request Body: $body",
      );

      // -------------------------------------------------------
      // Send request to Flask
      // -------------------------------------------------------

      final response = await http
          .post(
            Uri.parse("$apiUrl/predict"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      // -------------------------------------------------------
      // Response debug
      // -------------------------------------------------------

      debugPrint(
        "API Status Code: ${response.statusCode}",
      );

      debugPrint(
        "API Response: ${response.body}",
      );

      // -------------------------------------------------------
      // Success
      // -------------------------------------------------------

      if (response.statusCode == 200) {
        final dynamic decoded =
            jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          final Map<String, dynamic> result = decoded;

          if (result["success"] == true) {
            final String crop =
                result["recommended_crop"]
                    ?.toString() ??
                "";

            if (crop.isEmpty) {
              setState(() {
                errorMessage =
                    "Server returned an empty crop recommendation.";
              });

              return;
            }

            setState(() {
              recommendation =
                  "Recommended Crop: ${crop.toUpperCase()}";
            });
          } else {
            setState(() {
              errorMessage =
                  result["error"]?.toString() ??
                  "Prediction failed.";
            });
          }
        } else {
          setState(() {
            errorMessage =
                "Invalid response received from AI server.";
          });
        }
      }

      // -------------------------------------------------------
      // Bad request
      // -------------------------------------------------------

      else if (response.statusCode == 400) {
        String message =
            "Invalid input sent to AI server.";

        try {
          final dynamic decoded =
              jsonDecode(response.body);

          if (decoded is Map<String, dynamic>) {
            message =
                decoded["error"]?.toString() ??
                message;
          }
        } catch (_) {}

        setState(() {
          errorMessage = message;
        });
      }

      // -------------------------------------------------------
      // Server error
      // -------------------------------------------------------

      else if (response.statusCode >= 500) {
        setState(() {
          errorMessage =
              "AI server error (${response.statusCode}).\n\n"
              "Please check the Flask terminal.";
        });
      }

      // -------------------------------------------------------
      // Other errors
      // -------------------------------------------------------

      else {
        setState(() {
          errorMessage =
              "Server error: ${response.statusCode}\n\n"
              "${response.body}";
        });
      }
    }

    // ---------------------------------------------------------
    // Invalid number
    // ---------------------------------------------------------

    on FormatException {
      setState(() {
        errorMessage =
            "Please enter valid numbers in all fields.";
      });
    }

    // ---------------------------------------------------------
    // Connection error
    // ---------------------------------------------------------

    on SocketException {
      setState(() {
        errorMessage =
            "Cannot connect to AI server.\n\n"
            "Make sure:\n"
            "1. Flask server is running.\n"
            "2. Mobile and PC are connected to the same Wi-Fi.\n"
            "3. PC IP is 10.100.96.4.";
      });
    }

    // ---------------------------------------------------------
    // Timeout
    // ---------------------------------------------------------

    on http.ClientException catch (e) {
      setState(() {
        errorMessage =
            "Network error:\n$e";
      });
    }

    // ---------------------------------------------------------
    // Other errors
    // ---------------------------------------------------------

    catch (e) {
      debugPrint(
        "Prediction Error: $e",
      );

      setState(() {
        errorMessage =
            "Error: $e";
      });
    }

    // ---------------------------------------------------------
    // Stop loading
    // ---------------------------------------------------------

    finally {
      if (mounted) {
        setState(() {
          analyzing = false;
        });
      }
    }
  }

  // =========================================================
  // Image Options
  // =========================================================

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Select Crop Photo",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _optionButton(
                        icon: Icons.camera_alt,
                        title: "Camera",
                        onTap: () {
                          Navigator.pop(context);
                          pickImage(
                            ImageSource.camera,
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: _optionButton(
                        icon: Icons.photo_library,
                        title: "Gallery",
                        onTap: () {
                          Navigator.pop(context);
                          pickImage(
                            ImageSource.gallery,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // Option Button
  // =========================================================

  Widget _optionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(18),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffEAF7EF),
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xffB9E4C8),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 35,
              color: const Color(0xff07864B),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // Input Field
  // =========================================================

  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,

      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon: Icon(
          icon,
          color: const Color(0xff07864B),
        ),

        filled: true,

        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),

          borderSide:
              const BorderSide(
            color: Color(0xffB9E4C8),
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),

          borderSide:
              const BorderSide(
            color: Color(0xffB9E4C8),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),

          borderSide:
              const BorderSide(
            color: Color(0xff07864B),
            width: 2,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Build UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF6FBF8),

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        elevation: 0,

        backgroundColor:
            Colors.white,

        foregroundColor:
            const Color(0xff075F3D),

        title: const Text(
          "AI Crop Recommendation",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =================================================
            // HEADER
            // =================================================

            Container(
              width:
                  double.infinity,

              padding:
                  const EdgeInsets.all(22),

              decoration:
                  BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xff008A4B),
                    Color(0xff006B3A),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(
                  25,
                ),
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.agriculture,
                    color:
                        Colors.white,
                    size: 40,
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  Text(
                    "AI Crop Recommendation",
                    style: TextStyle(
                      color:
                          Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(
                    height: 8,
                  ),

                  Text(
                    "Enter soil and weather "
                    "information to get an "
                    "AI-based crop recommendation.",
                    style: TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            // =================================================
            // PHOTO
            // =================================================

            GestureDetector(
              onTap:
                  showImageOptions,

              child:
                  AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 300,
                ),

                width:
                    double.infinity,

                height: 250,

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    25,
                  ),

                  border:
                      Border.all(
                    color:
                        const Color(
                      0xffB9E4C8,
                    ),
                    width: 2,
                  ),
                ),

                child:
                    selectedImage ==
                            null
                        ? Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children: [
                              Container(
                                padding:
                                    const EdgeInsets
                                        .all(22),

                                decoration:
                                    const BoxDecoration(
                                  color:
                                      Color(
                                    0xffE5F6EB,
                                  ),
                                  shape:
                                      BoxShape
                                          .circle,
                                ),

                                child:
                                    const Icon(
                                  Icons
                                      .camera_alt_outlined,
                                  size: 50,
                                  color:
                                      Color(
                                    0xff07864B,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 18,
                              ),

                              const Text(
                                "Upload Crop Photo",
                                style:
                                    TextStyle(
                                  fontSize: 19,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color:
                                      Color(
                                    0xff075F3D,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              Text(
                                "Tap to choose "
                                "from camera or gallery",
                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .grey
                                          .shade600,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              23,
                            ),

                            child:
                                Image.file(
                              selectedImage!,
                              fit:
                                  BoxFit.cover,
                            ),
                          ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =================================================
            // CHANGE PHOTO
            // =================================================

            if (selectedImage != null)
              SizedBox(
                width:
                    double.infinity,

                child:
                    OutlinedButton.icon(
                  onPressed:
                      showImageOptions,

                  icon:
                      const Icon(
                    Icons.refresh,
                  ),

                  label:
                      const Text(
                    "Change Photo",
                  ),

                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(
                      0xff07864B,
                    ),

                    side:
                        const BorderSide(
                      color:
                          Color(
                        0xff07864B,
                      ),
                    ),

                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 15,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        15,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(
              height: 25,
            ),

            // =================================================
            // SOIL & WEATHER
            // =================================================

            const Text(
              "Soil & Weather Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xff075F3D),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // N
            _inputField(
              label:
                  "Nitrogen (N)",
              hint:
                  "Example: 90",
              controller:
                  nController,
              icon:
                  Icons.science_outlined,
            ),

            const SizedBox(
              height: 12,
            ),

            // P
            _inputField(
              label:
                  "Phosphorus (P)",
              hint:
                  "Example: 42",
              controller:
                  pController,
              icon:
                  Icons.science_outlined,
            ),

            const SizedBox(
              height: 12,
            ),

            // K
            _inputField(
              label:
                  "Potassium (K)",
              hint:
                  "Example: 43",
              controller:
                  kController,
              icon:
                  Icons.science_outlined,
            ),

            const SizedBox(
              height: 12,
            ),

            // Temperature
            _inputField(
              label:
                  "Temperature (°C)",
              hint:
                  "Example: 20.8",
              controller:
                  temperatureController,
              icon:
                  Icons.thermostat,
            ),

            const SizedBox(
              height: 12,
            ),

            // Humidity
            _inputField(
              label:
                  "Humidity (%)",
              hint:
                  "Example: 82",
              controller:
                  humidityController,
              icon:
                  Icons.water_drop_outlined,
            ),

            const SizedBox(
              height: 12,
            ),

            // pH
            _inputField(
              label:
                  "Soil pH",
              hint:
                  "Example: 6.5",
              controller:
                  phController,
              icon:
                  Icons.grass,
            ),

            const SizedBox(
              height: 12,
            ),

            // Rainfall
            _inputField(
              label:
                  "Rainfall (mm)",
              hint:
                  "Example: 202.9",
              controller:
                  rainfallController,
              icon:
                  Icons.cloudy_snowing,
            ),

            const SizedBox(
              height: 20,
            ),

            // =================================================
            // ANALYZE BUTTON
            // =================================================

            SizedBox(
              width:
                  double.infinity,

              height: 58,

              child:
                  ElevatedButton(
                onPressed:
                    analyzing
                        ? null
                        : analyzeCrop,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xff07864B,
                  ),

                  disabledBackgroundColor:
                      Colors.grey
                          .shade300,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                  ),
                ),

                child:
                    analyzing
                        ? const Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,

                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color:
                                      Colors
                                          .white,
                                ),
                              ),

                              SizedBox(
                                width: 12,
                              ),

                              Text(
                                "Getting Recommendation...",
                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .white,
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children: [
                              Icon(
                                Icons
                                    .auto_awesome,
                                color:
                                    Colors
                                        .white,
                              ),

                              SizedBox(
                                width: 10,
                              ),

                              Text(
                                "Get AI Recommendation",
                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .white,
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // =================================================
            // ERROR
            // =================================================

            if (errorMessage != null)
              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets.all(
                  18,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.red.shade50,

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),

                  border:
                      Border.all(
                    color:
                        Colors.red.shade200,
                  ),
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Icon(
                      Icons
                          .error_outline,
                      color:
                          Colors.red
                              .shade700,
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        errorMessage!,

                        style:
                            TextStyle(
                          color:
                              Colors.red
                                  .shade700,
                          height:
                              1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // =================================================
            // RESULT
            // =================================================

            if (recommendation != null)
              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets.all(
                  20,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),

                  border:
                      Border.all(
                    color:
                        const Color(
                      0xffB9E4C8,
                    ),
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.green
                              .withValues(
                        alpha: 0.08,
                      ),

                      blurRadius:
                          15,

                      offset:
                          const Offset(
                        0,
                        5,
                      ),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets
                                  .all(10),

                          decoration:
                              const BoxDecoration(
                            color:
                                Color(
                              0xffDFF5E7,
                            ),

                            shape:
                                BoxShape
                                    .circle,
                          ),

                          child:
                              const Icon(
                            Icons
                                .check_circle,
                            color:
                                Color(
                              0xff07864B,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        const Text(
                          "AI Recommendation",
                          style:
                              TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color:
                                Color(
                              0xff075F3D,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets
                              .all(18),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xffF0FAF3,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          15,
                        ),
                      ),

                      child: Text(
                        recommendation!,

                        style:
                            const TextStyle(
                          fontSize: 18,
                          height: 1.5,
                          fontWeight:
                              FontWeight
                                  .bold,
                          color:
                              Color(
                            0xff075F3D,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      "AI recommendation is based on the "
                      "soil and weather values entered above. "
                      "Use local agricultural guidance before "
                      "making farming decisions.",

                      style:
                          TextStyle(
                        fontSize: 12,
                        color:
                            Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}