import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/notification_router.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

// ================================================================
// GLOBAL NAVIGATOR KEY (NEW — 2026-09-27)
// ================================================================
//
// Lets a tapped system-tray push notification navigate even when
// there's no screen-level BuildContext yet — the app opened cold
// from a fully terminated state straight into whatever screen the
// notification is about. See _handleNotificationTap below.
//
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ================================================================
// FCM BACKGROUND MESSAGE HANDLER (NEW — 2026-09-27)
// ================================================================
//
// Must be a top-level function — FCM invokes this in its own
// isolate while the app is fully backgrounded or terminated.
// Deliberately does nothing: the "notification" half of the push
// payload (see functions/index.js's createNotification()) is what
// the OS uses to put this in the phone's notification shade
// automatically. There's nothing else to do here unless the app
// later needs to react to a push while it isn't even open.
//
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {}

// ================================================================
// HANDLE A TAPPED NOTIFICATION (NEW — 2026-09-27)
// ================================================================
//
// Shared by both tap paths below: the app was backgrounded (not
// terminated) when tapped (onMessageOpenedApp), or the app was
// opened cold BY tapping the notification (getInitialMessage).
// Routes through the same NotificationRouter the in-app bell list
// uses, so a system-tray tap and an in-app tap always land on the
// identical screen for the same notification.
//

void _handleNotificationTap(RemoteMessage message) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  NotificationRouter.open(
    context,
    type: message.data['type'] as String? ?? '',
    relatedId: message.data['relatedId'] as String?,
  );
}

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

  // ============================================================
  // PUSH NOTIFICATIONS (NEW — 2026-09-27)
  // ============================================================
  //
  // Puts a real notification in the phone's notification shade when
  // the app is backgrounded or closed (functions/index.js's
  // createNotification() now sends this alongside the existing
  // Firestore doc), and routes a tap to the actual screen the
  // notification is about. Registering this device's token against
  // the signed-in customer happens separately, right after login
  // (see login_screen.dart/otp_screen.dart) and on a warm relaunch
  // (splash_screen.dart) — there's no signed-in user yet at this
  // point on a fresh cold start.
  //

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.instance.onTokenRefresh.listen((_) {
    NotificationService.registerDeviceToken();
  });

  // A tap while the app was backgrounded (not terminated).
  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

  // The app was opened COLD by tapping the notification — checked
  // once, after the first frame so the navigator is actually ready.
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationTap(message);
    });
  });

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
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Habio',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
