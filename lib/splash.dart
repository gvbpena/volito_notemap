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

    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Text(
          'Loading...',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
