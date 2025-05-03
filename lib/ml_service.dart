import 'dart:io';
import 'package:tflite/tflite.dart';

class MLService {
  static Future<String> predictWeather(String imagePath) async {
    await Tflite.loadModel(
      model: "assets/weather_model.tflite",
      labels: "assets/labels.txt",
    );

    var output = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 1,
      threshold: 0.5,
    );

    if (output != null && output.isNotEmpty) {
      return output[0]['label'];
    } else {
      return 'Unknown';
    }
  }
}
