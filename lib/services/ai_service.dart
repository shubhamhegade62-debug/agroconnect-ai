// TODO Implement this library.
import 'package:flutter/material.dart';

class AiService {
  static Future<String> getMedicineRecommendation({
    required String cropName,
    required String symptom,
  }) async {
    return 'Consult a qualified agricultural expert for $cropName with $symptom.';
  }
}

Widget _medicineDetails() {
  return FutureBuilder<String>(
    future: AiService.getMedicineRecommendation(
      cropName: "Tomato",
      symptom: "Leaf Curl Disease",
    ),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (snapshot.hasError) {
        return const Text(
          "Couldn't load recommendation",
          style: TextStyle(color: Colors.red, fontSize: 11),
        );
      }

      final recommendation = snapshot.data ?? "No recommendation";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ...your existing "Recommended Medicine" badge stays the same
          Text(
            recommendation,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          // ...rest of your existing widgets
        ],
      );
    },
  );
}