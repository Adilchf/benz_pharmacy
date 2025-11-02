import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/user/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BenzPharmApp());
}

class BenzPharmApp extends StatelessWidget {
  const BenzPharmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BENZ PHARM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEC1E79), // pink accent
          primary: const Color(0xFFEC1E79),
          secondary: const Color(0xFF7AC943),
          background: const Color(0xFFF8F8F8),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3B3B3B),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEC1E79),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF3B3B3B), fontSize: 16),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B3B3B),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
