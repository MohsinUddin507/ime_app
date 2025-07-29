// constants.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0A0C3F);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color background = Color(0xFFF5F7FA);
  static const Color accent = Color(0xFF4CCD99);
  static const Color error = Color(0xFFE57373);
}

class AppText {
  static const String appName = 'IME Systems';
  static const String tagline = 'Smart Attendance System';
  static const String checkIn = 'Check-In';
  static const String checkOut = 'Check-Out';
  static const String noCamera = 'Camera not available';
  static const String cameraError = 'Failed to initialize camera';
  static const String defaultStatus = 'Position your face and tap check-in/out';
}

class AppDimens {
  static const double padding = 16.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 50.0;
  static const double splashLogoSize = 0.3; // 30% of screen size
}

class AppAssets {
  static const String logo = 'assets/images/logo.png';
}

class AppRoutes {
  static const String home = '/';
  static const String records = '/records';
  static const String register = '/register';
}