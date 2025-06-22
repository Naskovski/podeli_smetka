import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class CoinCounterService {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static int _inputWidth = 0;
  static int _inputHeight = 0;

  static const int _scoresOutputIndex = 0;
  static const int _boxesOutputIndex = 1;
  static const int _numDetectionsOutputIndex = 2;
  static const int _classesOutputIndex = 3;

  static Future<void> loadModel() async {
    try {
      if (_interpreter == null) {
        _interpreter = await Interpreter.fromAsset('assets/models/detect.tflite');
        var inputTensor = _interpreter!.getInputTensor(0);
        _inputHeight = inputTensor.shape[1];
        _inputWidth = inputTensor.shape[2];
      }

      if (_labels == null) {
        final labelTxt = await rootBundle.loadString('assets/models/labelmap.txt');
        _labels = labelTxt.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    } catch (e) {
      rethrow;
    }
  }

  static int _getCoinValue(String label) {
    final parts = label.split('-');
    if (parts.isNotEmpty) {
      try {
        return int.parse(parts[0]);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  static Future<Map<String, String>> analyze(XFile photo) async {
    if (_interpreter == null || _labels == null) {
      try {
        await loadModel();
      } catch (e) {
        return {'error': 'TFLite model or labels could not be loaded or configured: $e'};
      }
    }

    try {
      final Uint8List imageBytes = await photo.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        return {'error': 'Could not decode image from XFile.'};
      }

      img.Image resizedImage = img.copyResize(originalImage, width: _inputWidth, height: _inputHeight);

      var inputBatch = [
        List.generate(
          _inputHeight,
              (y) => List.generate(
            _inputWidth,
                (x) {
              final pixel = resizedImage.getPixel(x, y);
              return [
                (pixel.r.toDouble() - 127.5) / 127.5,
                (pixel.g.toDouble() - 127.5) / 127.5,
                (pixel.b.toDouble() - 127.5) / 127.5,
              ];
            },
          ),
        )
      ];

      int actualMaxDetections = 100;
      try {
        final scoresOutputTensorInfo = _interpreter!.getOutputTensor(_scoresOutputIndex);
        if (scoresOutputTensorInfo.shape.length > 1) {
          actualMaxDetections = scoresOutputTensorInfo.shape[1];
        }
      } catch (e) {
        // Fallback to default if dynamic determination fails.
      }

      var outputScores = List<List<double>>.filled(1, List<double>.filled(actualMaxDetections, 0.0));
      var outputBoxes = List<List<List<double>>>.filled(1, List<List<double>>.filled(actualMaxDetections, List<double>.filled(4, 0.0)));
      var outputClasses = List<List<double>>.filled(1, List<double>.filled(actualMaxDetections, 0.0));

      var outputNumDetections = List<double>.filled(1, 0.0);

      var outputs = <int, Object>{
        _scoresOutputIndex: outputScores,
        _boxesOutputIndex: outputBoxes,
        _classesOutputIndex: outputClasses,
        _numDetectionsOutputIndex: outputNumDetections,
      };

      _interpreter!.runForMultipleInputs([inputBatch], outputs);

      final List<double> scores = outputScores[0];
      final List<double> classes = outputClasses[0];
      final double numDetectionsValue = outputNumDetections[0];

      int numValidDetections = numDetectionsValue.toInt();
      if (numValidDetections > scores.length) {
        numValidDetections = scores.length;
      }

      Map<String, int> coinCounts = {};
      int totalValue = 0;

      for (int coinDenom in [1, 2, 5, 10, 50]) {
        coinCounts[coinDenom.toString()] = 0;
      }

      for (int i = 0; i < numValidDetections; i++) {
        if (scores[i] > 0.50) {
          int classId = classes[i].toInt();

          if (_labels != null && classId >= 0 && classId < _labels!.length) {
            String objectName = _labels![classId];
            int coinValue = _getCoinValue(objectName);

            print('Detected: Label: "$objectName", Class ID: $classId, Score: ${scores[i].toStringAsFixed(2)}');

            totalValue += coinValue;
            coinCounts.update(coinValue.toString(), (value) => value + 1, ifAbsent: () => 1);
          }
        }
      }

      Map<String, String> result = {
        'total': totalValue.toString(),
      };
      coinCounts.forEach((key, value) {
        result[key] = value.toString();
      });

      return result;
    } catch (e) {
      return {'error': 'Failed to analyze image: $e'};
    }
  }

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }
}
