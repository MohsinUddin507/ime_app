import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart' show InputImage, FaceDetectorOptions, FaceDetector;
import 'package:ime_app/attendance_logs_page.dart';
import 'package:path_provider/path_provider.dart';
import 'database_helper.dart';

class CheckInOutPage extends StatefulWidget {
  final CameraDescription camera;

  const CheckInOutPage({super.key, required this.camera});

  @override
  _CheckInOutPageState createState() => _CheckInOutPageState();
}

class _CheckInOutPageState extends State<CheckInOutPage> {
  late CameraController _cameraController;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  final FlutterTts _tts = FlutterTts();
  String _statusMessage = 'Position your face and tap check-in/out';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeTts();
  }

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    try {
      await _cameraController.initialize();
      if (mounted) {
        setState(() => _isCameraReady = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Failed to initialize camera: $e');
      }
    }
  }

  Future<void> _initializeTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
  }

  Future<void> _processCheckInOut(String type) async {
    if (!_isCameraReady || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing...';
    });

    try {
      // 1. Capture image
      final imageFile = await _cameraController.takePicture();
      
      // 2. Save image to permanent storage
      final permanentPath = await _saveImagePermanently(imageFile.path);
      
      // 3. Detect face (simplified - in real app you'd extract embeddings)
      final inputImage = InputImage.fromFilePath(permanentPath);
      final faceDetector = FaceDetector(options: FaceDetectorOptions());
      final faces = await faceDetector.processImage(inputImage);
      
      if (faces.isEmpty) {
        throw Exception('No face detected');
      }

      // 4. In real app: Compare with registered faces in database
      // For demo, we'll just use a dummy employee
      const employee = {
        'employee_id': 'EMP001',
        'name': 'Mohsin',
        'department': 'Development'
      };

      // 5. Save attendance record
    await DatabaseHelper.instance.createAttendanceRecord(
  employeeId: 'EMP001',
  name: 'Mohsin',
  type: 'check_in', // or 'check_out'
  imagePath: '/path/to/image.jpg',
);

      // 6. Update UI and give feedback
      final message = '$type successful for ${employee['name']}';
      setState(() => _statusMessage = '✅ $message\n'
          'Time: ${DateTime.now().hour}:${DateTime.now().minute}\n'
          'Employee ID: ${employee['employee_id']}');
      
      await _tts.speak(message);
    } catch (e) {
      setState(() => _statusMessage = '❌ Error: ${e.toString()}');
      await _tts.speak('Sorry, $type failed. Please try again.');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<String> _saveImagePermanently(String tempPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'attendance_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = '${directory.path}/$fileName';
    
    await File(tempPath).copy(newPath);
    return newPath;
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AttendanceRecordsPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isCameraReady
                ? CameraPreview(_cameraController)
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _statusMessage,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _processCheckInOut('check_in'),
                    icon: const Icon(Icons.login),
                    label: const Text('Check-In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _processCheckInOut('check_out'),
                    icon: const Icon(Icons.logout),
                    label: const Text('Check-Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
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