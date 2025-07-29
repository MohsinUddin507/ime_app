import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:ime_app/face_check_in_out_page.dart';
import 'constants.dart';

class SplashScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const SplashScreen({super.key, required this.cameras});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CheckInOutPage(
            camera:
                widget.cameras.first, // Provide the required camera parameter
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              AppAssets.logo,
              height:
                  MediaQuery.of(context).size.height * AppDimens.splashLogoSize,
              width:
                  MediaQuery.of(context).size.width * AppDimens.splashLogoSize,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.face_retouching_natural,
                size: 100,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: AppColors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
