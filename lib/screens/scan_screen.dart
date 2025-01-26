import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/counter_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription> cameras = [];
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras[0], // Use the first available camera (back camera)
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white54,),
          onPressed: () {
            Navigator.pop(context); // Pop the current screen and go back
          },
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // The camera is ready, display the camera preview
                return CameraPreview(_controller);
              } else {
                // Show a loading spinner until the camera is initialized
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          if (_isTakingPicture)
          // Show a loading spinner on top of the camera preview
            const Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, size: 40),
                  onPressed: _takePicture,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    setState(() {
      _isTakingPicture = true;
    });

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      // Send the captured image to CoinCounterService for analysis
      final result = await CoinCounterService.analyze(image);

      // Hide the loading spinner and show the result in a bottom sheet
      setState(() {
        _isTakingPicture = false;
      });

      _showBottomSheet(result);
    } catch (e) {
      print('Error taking picture: $e');
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  void _showBottomSheet(String result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                result,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
