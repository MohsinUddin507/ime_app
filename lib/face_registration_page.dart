import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'database_helper.dart';

class FaceRegistrationPage extends StatefulWidget {
  final CameraDescription camera;

  const FaceRegistrationPage({super.key, required this.camera});

  @override
  State<FaceRegistrationPage> createState() => _FaceRegistrationPageState();
}

class _FaceRegistrationPageState extends State<FaceRegistrationPage> {
  late CameraController _controller;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  bool _isInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    await _controller.initialize();
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  Future<void> _registerFace() async {
    if (_nameController.text.isEmpty || _employeeIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name and employee ID')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final image = await _controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final options = FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
      );
      final faceDetector = FaceDetector(options: options);
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No face detected. Please try again.')),
        );
        return;
      }

      // In a real app, you would extract face features/embeddings here

      await DatabaseHelper.instance.createFace(
        name: 'Mohsin',
        employeeId: 'EMP001',
        faceData: 'base64_encoded_face_data',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} registered successfully!'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register New Face')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isInitialized)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: CameraPreview(_controller),
              )
            else
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _employeeIdController,
              decoration: const InputDecoration(
                labelText: 'Employee ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Department (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isProcessing ? null : _registerFace,
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Register Face'),
            ),
          ],
        ),
      ),
    );
  }
}
