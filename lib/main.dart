import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'splash_screen.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final cameras = await availableCameras();
    runApp(MyApp(cameras: cameras)); // Pass cameras to MyApp
  } catch (e) {
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppText.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: SplashScreen(cameras: cameras), // Pass cameras to SplashScreen
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Camera initialization failed',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
