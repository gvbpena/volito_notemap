import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class SplashScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Delay and then determine which screen to show
    Future.delayed(const Duration(seconds: 3), () {
      final route = authService.currentUser != null ? '/home' : '/login';
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed(route);
    });

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
              onEnd: () {
                // You can add logic here if needed when animation ends
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading...',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
