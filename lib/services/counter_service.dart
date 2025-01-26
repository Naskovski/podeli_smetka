import 'package:camera/camera.dart';

class CoinCounterService {
  // Mock method for analyzing a coin photo
  static Future<String> analyze(XFile photo) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return '53 ден.'; // Mock result
  }
}
