import 'package:tflite/tflite.dart';

class TFLiteHelper {
  Future<void> loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/best_float16.tflite",
        labels: "assets/labels.txt", // Ensure you have a labels.txt file
      );
      print("Model loaded: $res");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<List<dynamic>?> runInference(String imagePath) async {
    try {
      return await Tflite.detectObjectOnImage(
        path: imagePath,
        model: "YOLO",
        threshold: 0.3,
        numResultsPerClass: 1,
      );
    } catch (e) {
      print("Error running inference: $e");
      return null;
    }
  }

  void close() {
    Tflite.close();
  }
}
