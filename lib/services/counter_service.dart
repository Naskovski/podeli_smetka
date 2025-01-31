import 'package:camera/camera.dart';

class CoinCounterService {
  static Future<Map<String, String>> analyze(XFile photo) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'total': '53',
      '1': '3',
      '2': '2',
      '5': '1',
      '10': '4',
      '50': '1',
    };
  }
}