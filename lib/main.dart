import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'home/home.dart';
import 'auth/login.dart';
import 'auth/register.dart';
import 'splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp(
    initialRoute: '/splash', // Start with the splash screen
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Volito NoteApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue, // Set primary swatch to blue
        ).copyWith(
          primary: Colors.blue[800], // Darker blue for primary color
          secondary: Colors.lightBlueAccent, // Light blue for accents
          surface: Colors.blue[50], // Soft background tone
          onPrimary: Colors.white, // Text color on primary buttons
          onSurface: Colors.black, // Text color on surfaces
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.blue, // Bold dark blue text for headings
          ),
          bodyLarge: TextStyle(
            color: Colors.black87, // Dimmed black for body text
          ),
        ),
      ),
      initialRoute: initialRoute, // Starts with the splash screen by default
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
