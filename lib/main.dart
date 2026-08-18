import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // NOTE: the old MatchingDemo dev harness that used to run here has
  // been removed — it wrote fake test requests through the mock
  // (non-Firestore) matching/opportunity services on every app
  // launch. Now that request submission goes through the real
  // Firestore-backed MatchingService/OpportunityService, running it
  // on every launch would create real junk data in Firestore.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habio',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}