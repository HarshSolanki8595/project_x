import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // TEMPORARY DEBUG LOGGING
  // ============================================================
  //
  // Enables verbose Firestore SDK logging (including low-level
  // gRPC/network request details) to Logcat. Added specifically
  // to diagnose a persistent PERMISSION_DENIED on the
  // collectionGroup('requests') bid-listener query that survives
  // even maximally permissive security rules and a confirmed
  // collection-group index. Remove once the root cause is found.
  //

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.setLoggingEnabled(true);

  // ============================================================
  // APP CHECK (added 2026-09-06, app-cloning hardening)
  // ============================================================
  //
  // Attaches a Play Integrity-verified token to every Firebase
  // Auth/Firestore/Storage/Functions request this app makes, so a
  // decompiled or repackaged clone of this APK -- even one that's
  // fully re-signed -- can't successfully talk to the real Habio
  // backend. In debug builds this uses the debug provider instead,
  // which prints a debug token to the console/Logcat on first run --
  // register that token once under Firebase Console > App Check >
  // Apps > (this app) > Manage debug tokens, or every debug run will
  // be rejected the same as an unrecognized client. Release builds
  // need no such registration: Play Integrity verifies automatically
  // once the app is signed with the real release key.
  //
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
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
