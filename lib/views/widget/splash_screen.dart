import 'package:autism_fyp/views/screens/locignscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/Videos/splash.mp4')
      ..initialize().then((_) {
        _controller.play();
        _controller.setVolume(1.0);
        _controller.setLooping(false);

        setState(() {});
      });

    // Navigate to LoginScreen after video ends or 4 seconds timeout
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        _goToLogin();
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) _goToLogin();
    });
  }

  void _goToLogin() {
    if (mounted) {
      Get.off(() => LoginScreen());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
